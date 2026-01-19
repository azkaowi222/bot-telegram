import Account from "../models/account.js";
import Product from "../models/product.js";

export const getAllAccounts = async (req, res) => {
  try {
    const accounts = await Account.find().populate("product").lean();
    return res.status(200).json({
      status: "success",
      data: accounts,
    });
  } catch (error) {
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const addAccount = async (req, res) => {
  try {
    const { productId, email, password, metadata } = req.body;
    const account = await Account.create({
      product: productId,
      email,
      password,
      metadata,
    });
    const product = await Product.findById(account.product).lean();
    return res.status(201).json({
      status: "success",
      data: {
        ...account.toObject(),
        product: {
          ...product,
        },
      },
    });
  } catch (error) {
    return res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const updateAccount = async (req, res) => {
  try {
    const { id } = req.params;
    const { productId, email, password, metadata } = req.body;
    const account = await Account.findByIdAndUpdate(
      id,
      {
        productId,
        email,
        password,
        metadata,
      },
      { new: true, runValidators: true },
    ).lean();
    const product = await Product.findById(productId).lean();
    return res.status(200).json({
      status: "success",
      data: {
        ...account,
        product,
      },
    });
  } catch (error) {
    return res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};
