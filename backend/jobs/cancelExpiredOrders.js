import cron from "node-cron";
import Order from "../models/order.js";
import Account from "../models/account.js";
import Payment from "../models/payment.js";

cron.schedule("* * * * *", async () => {
  const now = new Date();

  const expiredOrders = await Order.find({
    status: "pending",
    expiresAt: { $lte: now },
  })
    .populate("user")
    .lean();

  if (expiredOrders.length === 0) {
    console.log("No expired orders.");
    return;
  }

  console.log(`Found ${expiredOrders.length} expired orders`);

  for (const order of expiredOrders) {
    await Order.findOneAndUpdate(
      { _id: order._id, status: "pending" },
      {
        status: "expired",
      }
    );

    await Payment.findOneAndUpdate(
      { order: order._id, status: "pending" },
      {
        status: "expired",
      }
    );

    // Reset akun yang sudah di-reserve
    await Account.updateMany(
      { order: order._id, status: "reserved" },
      { status: "available", order: null }
    );

    await fetch("https://app.pakasir.com/api/transactioncancel", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        project: "Mannxstore-bot",
        order_id: order._id,
        amount: Number(`${order.totalPrice}000`),
        api_key: process.env.API_KEY,
      }),
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
          text: `⏰ *Waktu Pemabayaran Dengan Invoice* \`${order._id}\` *Telah Berakhir*

Pesanan dibatalkan. untuk membuat pesanan baru silahkan melakukan order ulang
          `,
          parse_mode: "Markdown",
        }),
      }
    );

    console.log(`Order ${order._id} canceled`);
  }
});
