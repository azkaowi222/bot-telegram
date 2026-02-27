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
    const { productId, email, password, status, metadata } = req.body;
    const account = await Account.findById(id);
    const isHasOrder = account.get("order");
    if (isHasOrder) {
      return res.status(409).json({
        status: "failed",
        message: "account has order",
      });
    }
    const accountUpdate = await Account.findOneAndUpdate(
      {
        _id: id,
      },
      {
        productId,
        email,
        password,
        metadata,
        status,
      },
      { new: true, runValidators: true },
    ).lean();
    const product = await Product.findById(productId).lean();
    return res.status(200).json({
      status: "success",
      data: {
        ...accountUpdate,
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

export const deleteAccount = async (req, res) => {
  try {
    const { id } = req.params;
    console.log(id);
    if (!id) {
      throw Error("Required Id");
    }
    await Account.findByIdAndDelete(id);
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
