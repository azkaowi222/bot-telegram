import mongoose from "mongoose";

const orderSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    totalPrice: { type: Number, required: true },
    status: {
      type: String,
      enum: ["pending", "paid", "delivered", "failed", "expired"],
      default: "pending",
    },
    paymentMethod: { type: String, default: "qris" },
    expiresAt: { type: Date, required: true },
  },
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
