import mongoose from "mongoose";

const accountSchema = new mongoose.Schema(
  {
    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    metadata: { type: Object }, // tambahan info (login URL, token, dsb)
    status: {
      type: String,
      enum: ["available", "sold", "reserved"],
      default: "available",
    },
    soldAt: { type: Date },
    order: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      default: null,
    },
  },
  { timestamps: true },
);

export default mongoose.model("Account", accountSchema);
