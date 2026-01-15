import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config({
  quiet: true,
});

const uri = process.env.DATABASE_URI;

const dbConnect = async () => {
  try {
    await mongoose.connect(uri, {
      dbName: "Mannxstore-db",
    });
    console.log("db connected...");
  } catch (error) {
    console.error(`error connection ${error.message}`);
    process.exit(1);
  }
};

export default dbConnect;
