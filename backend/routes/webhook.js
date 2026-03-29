import mongoose from "mongoose";
import express from "express";
import Order from "../models/order.js";
import User from "../models/user.js";
import Payment from "../models/payment.js";
import OrderItem from "../models/orderItem.js";
import Account from "../models/account.js";
import { google } from "googleapis";
import dotenv from "dotenv";

dotenv.config({
  quiet: true,
});

const router = express.Router();

router.post("/webhook/callback", async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const data = req.body;

    // 1. Cari order
    const order = await Order.findById(data.order_id)
      .populate("user")
      .session(session);
    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    // 2. Jika order sudah paid → jangan proses ulang
    if (order.status === "paid") {
      return res.status(200).json({ message: "Already processed" });
    }

    // 3. Validasi status pembayaran
    if (data.status !== "completed") {
      return res.status(400).json({ message: "Payment failed" });
    }

    // 4. Update order & payment
    await Order.findByIdAndUpdate(
      data.order_id,
      { status: "paid" },
      { session },
    );

    await Payment.findOneAndUpdate(
      { order: data.order_id },
      { status: "paid" },
      { session },
    );

    // 5. Ambil semua item dari OrderItem
    const items = await OrderItem.find({ order: data.order_id }).session(
      session,
    );

    const deliveredAccounts = [];

    // 6. Ambil akun yang sudah reserved
    for (const item of items) {
      const accounts = await Account.find({
        order: data.order_id,
        product: item.product,
        status: "reserved",
      })
        .limit(item.quantity)
        .session(session);

      for (const acc of accounts) {
        acc.status = "sold";
        acc.soldAt = new Date();
        await acc.save({ session });
        deliveredAccounts.push(acc);
      }
    }

    const accountToSend = deliveredAccounts.map((account) => {
      return `
✉️ Email/Username: 
\`${account.email}\`
🔒 Password: 
\`${account.password}\`
🗝️ 2FA: 
\`${account.metadata["2fa"]}\`
`;
    });
    await sendMessageWithRetry(order, accountToSend);
    const accesToken = await getAccessToken();
    const admin = await User.findOne({
      telegramId: process.env.ADMIN_ID,
    }).lean();
    if (!admin) {
      throw new Error("Admin dengan Telegram ID tersebut tidak ditemukan");
    }
    const fcmToken = admin.fcmToken;
    await fetch(
      "https://fcm.googleapis.com/v1/projects/first-project-a76cd/messages:send",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accesToken}`,
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: {
              body: "Ada Orderan baru nich!!",
              title: "FCM Message",
            },
            android: {
              priority: "normal",
              notification: {
                channel_id: "high_importance_channel",
              },
            },
            webpush: {
              headers: {
                Urgency: "high",
              },
            },
          },
        }),
      },
    );

    await session.commitTransaction();
    session.endSession();

    return res.status(200).json({
      status: "success",
      data: deliveredAccounts,
    });
  } catch (error) {
    console.log(`ada error $${error.message}`);
    await session.abortTransaction();
    session.endSession();
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
});

function getAccessToken() {
  return new Promise(function (resolve, reject) {
    const credentials = JSON.parse(process.env.FIREBASE_JSON);
    console.log(credentials.private_key);
    const jwtClient = new google.auth.JWT({
      email: credentials.client_email,
      key: credentials.private_key,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });
    jwtClient.authorize(function (err, tokens) {
      if (err) {
        reject(err);
        return;
      }
      resolve(tokens.access_token);
    });
  });
}

const delay = (ms) => new Promise((res) => setTimeout(res, ms));

const sendMessageWithRetry = async (order, accountToSend, retry = 3) => {
  try {
    return await fetch(
      `https://api.telegram.org/bot${process.env.BOT_TOKEN}/sendMessage`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          chat_id: order.user.telegramId,
          text: `===========================
💰 Pembayaran berhasil!
Pesanan Anda sudah diproses.
===========================

📦 *Informasi Akun*:

${accountToSend.join("")}

Terimakasih sudah order di MannStore 😊.
Semoga awet dan lancar. Ditunggu order selanjutnya...`,
          parse_mode: "Markdown",
        }),
      },
    );
  } catch (err) {
    if (err.response?.status === 429 && retry > 0) {
      const wait = err.response.data.parameters?.retry_after || 1;
      console.log(`Retry after ${wait}s...`);
      await delay(wait * 1000);

      return sendMessageWithRetry(order, accountToSend, retry - 1);
    }

    throw err;
  }
};

export default router;
