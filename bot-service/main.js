import { Input, Markup, session, Telegraf } from "telegraf";
import qrcode from "qrcode";
import dotenv from "dotenv";
import http from "http";

dotenv.config({
  quiet: true,
});

const tips =
  "💡 Tips Login aman: Gunakan ip indo karena ini menggunakan billing indo & login menggunakan mode penyamaran. Garansi berlaku jika akun tidak bisa login, gagal membuat instance pertama, dan saldo tidak sesuai. garansi berlaku 3 hari sejak dilakukan pembelian";

const bot = new Telegraf(process.env.BOT_TOKEN);
bot.use(
  session({
    defaultSession: () => {
      return {
        qty: 1,
      };
    },
  }),
);

let products = [];
const getProducts = async () => {
  products = [];
  const response = await fetch(`${process.env.BACKEND_URL}/api/products`);
  const { _, data } = await response.json();
  products = data.map((item) => {
    return {
      ...item,
    };
  });
};

const onBuyHandler = async (ctx) => {
  await ctx.answerCbQuery();
  const id = ctx.match[1];
  const { id: telegramId } = ctx.from;
  const userResponse = await fetch(
    `${process.env.BACKEND_URL}/api/user/${telegramId}`,
  );
  const {
    data: { _id },
  } = await userResponse.json();
  const product = products.find((product) => product._id === id);
  const prefix = product.name.split(" ")[0];
  if (ctx.session[`${prefix}stock`] === 0) {
    return await ctx.answerCbQuery("⚠️ Maaf stock kosong!", {
      show_alert: true,
    });
  }
  if (!ctx.session[`${prefix}qty`]) ctx.session[`${prefix}qty`] = 1;
  try {
    const response = await fetch(`${process.env.BACKEND_URL}/api/order`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user: _id,
        items: [
          {
            id: product._id,
            quantity: +ctx.session[`${prefix}qty`],
          },
        ],
      }),
    });
    const data = await response.json();
    if (!response.ok) {
      throw new Error(data.message);
    }
    const qr = await qrcode.toBuffer(data.payment.payment_number, {
      errorCorrectionLevel: "H",
      type: "png",
      margin: 10,
      width: 300,
    });
    const productPrice = Number(`${product.price}000`);
    const fee = Number(data.payment.fee);
    const total = Intl.NumberFormat("id-ID", {
      minimumFractionDigits: 0,
      currency: "IDR",
      style: "currency",
    }).format(productPrice * ctx.session[`${prefix}qty`] + fee);
    await ctx.answerCbQuery("Membuat Invoice Pembayaran...");
    await ctx.deleteMessage();
    await ctx.replyWithPhoto(
      {
        source: qr,
      },
      {
        caption: `
🧾 *Invoice Pembayaran*

🆔 Order-ID: \`${data.payment.order_id}\`
📦 Produk: ${product.name}
💵 Harga: ${product.price}K
🔢 Jumlah: ${ctx.session[`${prefix}qty`]}
🪙 Fee: ${fee}
💰 Total: ${total}

📱 *Instruksi Pembayaran*
Scan QR-CODE diatas untuk melakukan pembayaran. Bisa menggunakan E-wallet atau M-Banking.

📌 Akun otomatis akan dikirimkan ketika pembayaran berhasil.

⏰ Pesanan akan dibatalkan otomatis dalam waktu 5 menit jika tidak ada pembayaran. 
        `,
        parse_mode: "Markdown",
      },
    );
  } catch (error) {
    console.error(`catch error ${error.message}`);
  }
};

const historyHandler = async (ctx) => {
  await ctx.sendChatAction("typing");
  await ctx.answerCbQuery();
  const telegramId = ctx.from.id;

  const response = await fetch(
    `${process.env.BACKEND_URL}/api/order/history/${telegramId}`,
  );
  const result = await response.json();
  if (!result.data || result.data.length === 0) {
    return ctx.reply("📭 Anda belum memiliki riwayat order.");
  }

  let text = "🧾 *Riwayat Order*\n\n";

  for (const order of result.data) {
    text += `🆔 Order: \`${order._id}\`\n`;
    text += `📅 Tanggal: *${new Date(order.createdAt).toLocaleString(
      "id-ID",
    )}*\n`;
    text += `💵 Total: *Rp ${order.totalPrice.toLocaleString("id-ID")}K*\n`;
    text += `📌 Status: *${order.status}*\n`;

    // tampilkan itemnya
    for (const item of order.items) {
      text += `  • ${item.product.name} x ${item.quantity}\n`;
    }

    text += `\n──────────────\n\n`;
  }

  return ctx.reply(text, {
    parse_mode: "Markdown",
    reply_markup: Markup.inlineKeyboard([
      [Markup.button.callback("🔙 Kembali", "back")],
    ]),
  });
};

const mainMenu = async (ctx) => {
  try {
    const { first_name, last_name, id, username } = ctx.from;
    const response = await fetch(`${process.env.BACKEND_URL}/api/register`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        firstName: first_name,
        lastName: last_name,
        telegramId: id,
        username,
      }),
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.message);
    await ctx.sendChatAction("typing");
    return ctx.replyWithPhoto(
      Input.fromLocalFile("./asset/images/greetings.png"),
      {
        caption: `👋 Hi <b>${first_name}</b>, Welcome to <b>MannStore</b> 🏡\nKami Menyediakan Layanan Akun Cloud Berkualitas Dan Bergaransi`,
        parse_mode: "HTML",
        reply_markup: {
          inline_keyboard: [
            [
              Markup.button.callback("🛒 Mulai Belanja", "shop"),
              Markup.button.callback("🧾 Riwayat Order", "history"),
            ],
            [Markup.button.url("🆘 Bantuan", "https://t.me/Armann_29")],
          ],
        },
      },
    );
  } catch (error) {
    console.error(error.message);
  }
};

const chunkArray = (arr, size) => {
  const result = [];
  for (let i = 0; i < arr.length; i += size) {
    result.push(arr.slice(i, i + size));
  }
  return result;
};

const listProduct = async (ctx) => {
  const productButtons = products.map((product, i) =>
    Markup.button.callback(`${i + 1}`, `product_${product._id}`),
  );
  const rows = chunkArray(productButtons, 2);
  await getProducts();
  const listProducts = products.map((product) => {
    return product.name;
  });
  return ctx.replyWithHTML(
    `List produk di <b>MannStore</b>\n\n${listProducts
      .map((product, i) => {
        return `[ ${i + 1} ] ${product}\n`;
      })
      .join("")}\n\nPilih Akun :`,
    Markup.inlineKeyboard([
      ...rows,
      [Markup.button.callback("🔙 Kembali", "back")],
    ]),
  );
};

const detailProducts = (
  ctx,
  product = {
    productId: "",
    name: "",
    price: 0,
    balance: 0,
    quantity: 1,
    stock: 0,
  },
) => {
  return ctx.editMessageText(
    `📦 Detail Product\n\n🏷️ Nama: ${product.name}\n💵 Saldo: ${
      product.balance ? `$${product.balance}` : product.balance
    }\n💰 Harga: ${product.price * product.quantity}k\n🛍️ Stock: ${
      product.stock ?? 0
    }\n\n${tips}`,
    {
      parse_mode: "HTML",
      reply_markup: {
        inline_keyboard: [
          [
            Markup.button.callback("➖", `minus_${product.productId}`),
            Markup.button.callback(product.quantity.toString(), "qty"),
            Markup.button.callback("➕", `plus_${product.productId}`),
          ],
          [
            Markup.button.callback("🔙 Kembali", `backFromDetails`),
            Markup.button.callback(
              "💰 Beli Sekarang",
              `buy_${product.productId}`,
            ),
          ],
        ],
      },
    },
  );
};

bot.start(async (ctx) => {
  await mainMenu(ctx);
});

bot.action("shop", async (ctx) => {
  await ctx.answerCbQuery();
  await ctx.deleteMessage();
  await listProduct(ctx);
});

bot.action("back", async (ctx) => {
  const { first_name } = ctx.from;
  await ctx.editMessageMedia(
    {
      type: "photo",
      media: {
        source: "./asset/images/greetings.png",
      },
      caption: {
        text: `👋 Hi <b>${first_name}</b>, Welcome to <b>MannStore</b>\nKami Menyediakan Layanan Akun Cloud Berkualitas Dan Bergaransi.`,
      },
      parse_mode: "HTML",
    },
    {
      reply_markup: {
        inline_keyboard: [
          [
            Markup.button.callback("🛒 Mulai Belanja", "shop"),
            Markup.button.callback("🧾 Riwayat Order", "history"),
          ],
          [Markup.button.url("🆘 Bantuan", "https://t.me/Armann_29")],
        ],
      },
    },
  );
});

bot.action(/^product_(.+)$/, async (ctx) => {
  const id = ctx.match[1];
  const product = products.find((p) => p._id === id);
  const prefix = product.name.split(" ")[0];
  ctx.session[`${prefix}qty`] = 1;
  ctx.session.productId = id;

  try {
    const response = await fetch(
      `${process.env.BACKEND_URL}/api/stock/${product._id}`,
    );
    const { stock } = await response.json();
    ctx.session[`${prefix}stock`] = stock;
    await detailProducts(ctx, {
      productId: product._id,
      name: product.name,
      balance: product.balance,
      price: product.price,
      quantity: ctx.session[`${prefix}qty`],
      stock,
    });
  } catch (error) {
    console.error(`Error checking stock ${error.message}`);
  }
});

bot.action("backFromDetails", async (ctx) => {
  const productButtons = products.map((product, i) =>
    Markup.button.callback(`${i + 1}`, `product_${product._id}`),
  );
  const rows = chunkArray(productButtons, 2);
  await getProducts();
  const listProducts = products.map((product) => {
    return product.name;
  });
  return ctx.editMessageText(
    `List produk di <b>MannStore</b>\n\n${listProducts
      .map((product, i) => {
        return `[ ${i + 1} ] ${product}\n`;
      })
      .join("")}\n\nPilih Akun :`,
    {
      parse_mode: "HTML",
      reply_markup: {
        inline_keyboard: [
          ...rows,
          [Markup.button.callback("🔙 Kembali", "back")],
        ],
      },
    },
  );
});

bot.action(/^plus_(.+)$/, async (ctx) => {
  const currentId = ctx.match[1];
  const product = products.find((p) => p._id === currentId);
  const prefix = product?.name.split(" ")[0];

  try {
    const response = await fetch(
      `${process.env.BACKEND_URL}/api/stock/${product._id}`,
    );
    const { stock } = await response.json();

    if (stock === 0) {
      return await ctx.answerCbQuery("⚠️ Maaf stock kosong!", {
        show_alert: true,
      });
    }

    if (ctx.session[`${prefix}qty`] >= stock) {
      return ctx.answerCbQuery("⚠️ Stok tidak mencukupi!", {
        show_alert: true,
      });
    }
    ctx.session[`${prefix}qty`]++;
    await detailProducts(ctx, {
      productId: product._id,
      name: product.name,
      balance: product.balance,
      price: product.price,
      quantity: ctx.session[`${prefix}qty`],
      stock,
    });
  } catch (error) {
    console.error(`Error checking stock ${error.message}`);
  }
});

bot.action(/^minus_(.+)$/, async (ctx) => {
  const currentId = ctx.match[1];
  const product = products.find((p) => p._id === currentId);
  const prefix = product?.name.split(" ")[0];

  if (ctx.session[`${prefix}qty`] <= 1) {
    return ctx.answerCbQuery("⚠️ Minimal Pemesanan 1!", { show_alert: true });
  }
  ctx.session[`${prefix}qty`]--;

  try {
    const response = await fetch(
      `${process.env.BACKEND_URL}/api/stock/${product._id}`,
    );
    const { stock } = await response.json();

    if (stock === 0) {
      return await ctx.answerCbQuery("⚠️ Maaf stock kosong!");
    }

    await detailProducts(ctx, {
      productId: product._id,
      name: product.name,
      balance: product.balance,
      price: product.price,
      quantity: ctx.session[`${prefix}qty`],
      stock,
    });
  } catch (error) {
    console.error(`Error checking stock ${error.message}`);
  }
});

bot.action(/^buy_(.+)$/, onBuyHandler);

bot.action("history", historyHandler);

bot.launch(async () => {
  console.log("running bot...");
  await getProducts().catch(console.log);
});

const port = process.env.PORT || 4000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.end("Bot is running smoothly!");
});

server.listen(port, () => {
  console.log(`Dummy server listening on port ${port}`);
});
// Enable graceful stop
process.once("SIGINT", () => bot.stop("SIGINT"));
process.once("SIGTERM", () => bot.stop("SIGTERM"));
