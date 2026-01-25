import mongoose from "mongoose";
import Order from "../models/order.js";
import OrderItem from "../models/orderItem.js";
import Product from "../models/product.js";
import Payment from "../models/payment.js";
import Account from "../models/account.js";
import User from "../models/user.js";

export const createOrder = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const { user, items } = req.body;
    const expiredOrders = new Date(Date.now() + 2 * 60 * 1000);

    let totalPrice = 0;
    const order = await Order.create(
      [{ user, totalPrice: 0, expiresAt: expiredOrders }],
      {
        session,
      }
    );
    const createdOrderItems = [];

    for (const item of items) {
      const product = await Product.findById(item.id);
      if (!product) throw new Error("Product not found");

      if (item.quantity <= 0) throw new Error("Minimum 1 item");

      const availableAccounts = await Account.find({
        product: product._id,
        status: "available",
      })
        .limit(item.quantity)
        .session(session);

      if (availableAccounts.length < item.quantity)
        throw new Error("Stock not enough");

      // hitung subtotal
      const subtotal = product.price * item.quantity;
      totalPrice += subtotal;

      // buat order item
      const orderItem = await OrderItem.create(
        [
          {
            order: order[0]._id,
            product: product._id,
            nameSnapshot: product.name,
            price: product.price,
            quantity: item.quantity,
            subtotal,
            accounts: availableAccounts.map((acc) => acc._id),
          },
        ],
        { session }
      );

      createdOrderItems.push(orderItem);

      // reserve akun yang terpilih
      for (const acc of availableAccounts) {
        acc.status = "reserved";
        acc.order = order[0]._id;
        await acc.save({ session });
      }
    }

    // buat payment entry
    const payment = await Payment.create(
      [
        {
          order: order[0]._id,
          amount: totalPrice,
          method: "qris",
          status: "pending",
        },
      ],
      { session }
    );

    // update total price
    await Order.findByIdAndUpdate(order[0]._id, { totalPrice }, { session });

    const response = await fetch(
      "https://app.pakasir.com/api/transactioncreate/qris",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          project: "Mannxstore-bot",
          order_id: order[0]._id,
          amount: Number(`${payment[0].amount}000`),
          api_key: process.env.API_KEY,
        }),
      }
    );

    const data = await response.json();

    await session.commitTransaction();
    session.endSession();

    res.status(201).json({
      status: "success",
      orderId: order[0]._id,
      items: createdOrderItems,
      payment: data.payment,
    });
  } catch (error) {
    await session.abortTransaction();
    session.endSession();

    res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const getAllOrders = async (req, res) => {
  const fullInfoOrders = [];
  try {
    const orders = await Order.find().populate("user").lean();
    for (const order of orders) {
      const product = await OrderItem.findOne({
        order: order._id,
      })
        .populate("product")
        .lean();
      fullInfoOrders.push({
        soldBy: order.user.username ?? order.user.telegramId,
        product: product.nameSnapshot,
        status: order.status,
        payment: order.paymentMethod,
        image_path: product.product.image_path ?? "no path",
        date: order.createdAt,
      });
    }
    return res.status(200).json({
      status: "success",
      data: fullInfoOrders,
    });
  } catch (error) {
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const getOrderById = async (req, res) => {
  try {
    const { id } = req.params;
    const orders = await Order.findById(id).lean();
    return res.status(201).json({
      status: "success",
      data: orders,
    });
  } catch (error) {
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const getOrderHistory = async (req, res) => {
  try {
    const { telegramId } = req.params;
    const user = await User.findOne({
      telegramId,
    });

    if (!user || user.length === 0) {
      return res.status(404).json({
        status: "failed",
        message: "user not found",
      });
    }

    // Cari semua order berdasarkan user.telegramId
    const orders = await Order.find({ user: user._id, status: "paid" })
      .sort({ createdAt: -1 })
      .lean();

    if (orders.length === 0) {
      return res.status(200).json({
        status: "success",
        message: "you doesnt have any history",
      });
    }

    // Ambil item untuk setiap order
    for (const order of orders) {
      const items = await OrderItem.find({ order: order._id })
        .populate("product")
        .lean();
      order.items = items;
    }

    return res.status(200).json({
      status: "success",
      data: orders,
    });
  } catch (error) {
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
};
