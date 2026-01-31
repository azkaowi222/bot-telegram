import mongoose from "mongoose";
import express from "express";
import Order from "../models/order.js";
import Payment from "../models/payment.js";
import OrderItem from "../models/orderItem.js";
import Account from "../models/account.js";

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

    await fetch(
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

    await session.commitTransaction();
    session.endSession();

    return res.status(200).json({
      status: "success",
      data: deliveredAccounts,
    });
  } catch (error) {
    await session.abortTransaction();
    session.endSession();
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
});

export default router;
