import path from "path";
import Account from "../models/account.js";
import Product from "../models/product.js";
import Users from "../models/user.js";
import mongoose from "mongoose";

export const getAllProducts = async (req, res) => {
  try {
    // Github Student Pack
    // // Mail .edu (microsoft)
    // const products = await Product.updateOne(
    //   {
    //     name: "Mail .edu (microsoft)",
    //   },
    //   {
    //     image_path: "email_edu.jpg",
    //   }
    // );
    // const stockAzure = await Account.find({
    //   product: "6934f902a2bd1f55eeb4d09c",
    // }).countDocuments();
    // const products = await Product.find().lean();
    await Product.deleteMany({
      name: "liking",
    });

    const products = await Product.aggregate([
      {
        $lookup: {
          from: "accounts",
          localField: "_id",
          foreignField: "product",
          as: "accounts",
        },
      },
      {
        $addFields: {
          stock: {
            $size: {
              $filter: {
                input: "$accounts",
                as: "acc",
                cond: { $eq: ["$$acc.status", "available"] },
              },
            },
          },
        },
      },
      {
        $project: {
          accounts: 0, // tidak kirim data account
        },
      },
    ]);

    return res.status(200).json({
      status: "success",
      data: products,
      // stockAzure,
    });
  } catch (error) {
    return res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const getProductById = async (req, res) => {
  try {
    const { id } = req.params;
    const product = await Product.findById(id);
    return res.status(200).json({
      status: "success",
      data: product,
    });
  } catch (error) {
    return res.status(404).json({
      status: "failed",
      message: "product not found",
    });
  }
};

export const createProduct = async (req, res) => {
  const session = await mongoose.startSession();

  try {
    session.startTransaction();

    const { name, description, balance, price, category, isActive } = req.body;
    const { image } = req.files;

    if (!req.files || Object.keys(req.files).length === 0) {
      throw new Error("No files were uploaded");
    }

    const image_path = image.name;

    const product = await Product.create(
      [
        {
          name,
          description,
          balance,
          price,
          category,
          image_path,
          isActive,
        },
      ],
      { session }
    );

    const stock = await Account.countDocuments(
      {
        product: product[0]._id,
        status: "available",
      },
      { session }
    );

    const dirname = import.meta.dirname;
    const uploadPath = path.join(
      dirname.replace("controller", ""),
      "public",
      image_path
    );

    await image.mv(uploadPath);

    // ✅ WAJIB
    await session.commitTransaction();
    session.endSession();

    return res.status(201).json({
      status: "success",
      data: product[0],
      stock,
    });
  } catch (error) {
    await session.abortTransaction();
    session.endSession();

    return res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, balance, price, category, isActive } = req.body;
    const product = await Product.findByIdAndUpdate(id, {
      name,
      description,
      balance,
      price,
      category,
      isActive,
    }).lean();
    return res.status(200).json({
      status: "success",
      data: {
        ...product,
        name,
      },
    });
  } catch (error) {
    return res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const deleteProduct = async (req, res) => {
  try {
    const { id, name } = req.body;
    console.log(id, name);
    if (!id && !name) {
      throw Error("Required One, Id or name");
    }
    if (!name && id) {
      await Product.findByIdAndDelete(id);
      return;
    }
    await Product.findOneAndDelete({
      name,
    });
    return res.status(200).json({
      status: "success",
      message: "deleted succesfully",
    });
  } catch (error) {
    return res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const cekStock = async (req, res) => {
  const { id } = req.params;

  try {
    const stock = await Account.countDocuments({
      product: id,
      status: "available",
    });

    if (stock === 0) {
      return res.status(200).json({
        status: "success",
        message: "out of stock",
        stock,
      });
    }

    return res.status(200).json({
      status: "success",
      stock,
    });
  } catch (error) {
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
};

// Helper function untuk delay (jeda waktu)
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

export const sendBroadcast = async (req, res) => {
  const { message } = req.body;

  if (!message) {
    return res.status(400).json({
      status: "failed",
      message: "text message field required",
    });
  }

  try {
    const users = await Users.find().lean();

    // Siapkan variabel untuk laporan
    let successCount = 0;
    let failCount = 0;
    const errors = [];

    // PROSES PENGIRIMAN
    // Kita loop user, tapi kita bungkus try-catch DI DALAM loop
    // agar kalau 1 gagal, yang lain tetap jalan.
    for (const user of users) {
      if (!user.telegramId) continue; // Skip jika tidak ada ID

      try {
        const response = await fetch(
          `https://api.telegram.org/bot${process.env.BOT_TOKEN}/sendMessage`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              chat_id: user.telegramId,
              text: message,
            }),
          }
        );

        const data = await response.json();

        if (!data.ok) {
          // Jika Telegram menolak (misal: user memblokir bot)
          failCount++;
          errors.push({ userId: user.telegramId, error: data.description });
        } else {
          successCount++;
        }
      } catch (err) {
        // Jika error jaringan / fetch gagal
        failCount++;
        errors.push({ userId: user.telegramId, error: err.message });
      }

      // PENTING: Beri jeda sedikit agar tidak kena Rate Limit Telegram
      // 50ms = 20 pesan per detik (aman)
      await sleep(50);
    }

    // Response mengembalikan laporan lengkap
    return res.status(200).json({
      status: "success",
      report: {
        total_users: users.length,
        sent_success: successCount,
        sent_failed: failCount,
        errors_sample: errors.slice(0, 5), // Tampilkan 5 error pertama saja agar tidak penuh
      },
    });
  } catch (error) {
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
};
