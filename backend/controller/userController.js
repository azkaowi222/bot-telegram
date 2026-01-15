import User from "../models/user.js";

export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find().lean();
    return res.status(200).json({
      status: "success",
      data: users,
    });
  } catch (error) {
    return res.status(500).json({
      status: "failed",
      message: error.message,
    });
  }
};

export const getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findOne({
      telegramId: id,
    }).lean();
    return res.status(200).json({
      status: "success",
      data: user,
    });
  } catch (error) {
    return res.status(404).json({
      status: "failed",
      message: "User not found",
    });
  }
};

export const createUser = async (req, res) => {
  try {
    const {
      telegramId,
      username = "noUsername",
      firstName,
      lastName,
    } = req.body;

    const user = await User.find({
      telegramId,
    });
    if (user.length >= 1) {
      return res.status(200).json({
        status: "success",
        message: "user already register",
      });
    }
    const newUser = await User.create({
      telegramId,
      username: `@${username}`,
      firstName,
      lastName,
    });
    return res.status(201).json({
      status: "success",
      data: newUser,
    });
  } catch (error) {
    return res.status(400).json({
      status: "failed",
      message: error.message,
    });
  }
};
