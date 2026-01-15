import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    telegramId: { type: Number, required: true, unique: true },
    username: { type: String },
    firstName: { type: String },
    lastName: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);
