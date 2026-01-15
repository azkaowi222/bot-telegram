import mongoose from "mongoose";

const productSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    description: { type: String },
    balance: { type: Number, default: 0 }, // contoh: $100
    price: { type: Number, required: true }, // contoh: 100k
    category: { type: String },
    image_path: { type: String },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export default mongoose.model("Product", productSchema);
