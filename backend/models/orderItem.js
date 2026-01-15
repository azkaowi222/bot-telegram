import mongoose from "mongoose";

const orderItemSchema = new mongoose.Schema(
  {
    order: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      required: true,
    },
    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    nameSnapshot: { type: String, required: true },
    quantity: { type: Number, required: true },
    price: { type: Number, required: true }, // harga pada saat transaksi
    subtotal: { type: Number, required: true }, // quantity × price
  },
  { timestamps: true }
);

export default mongoose.model("OrderItem", orderItemSchema);
