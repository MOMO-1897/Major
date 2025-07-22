const mongoose = require("mongoose");
const { Schema, model, Types } = mongoose;

const LastMessageSchema = new Schema({
  content: { type: String, required: true },
  timestamp: { type: Date, required: true },
  senderId: { type: Types.ObjectId, ref: "User", required: true },
  type: {
    type: String,
    enum: ["TEXT", "IMAGE"],
    default: "TEXT",
  },
}, { _id: false });

const ConversationSchema = new Schema(
  {
    participants: {
      type: [Types.ObjectId],
      ref: "User",
      required: true,
      validate: {
        validator: function (v) {
          return Array.isArray(v) && v.length === 2;
        },
        message: "Participants must be an array of exactly two user IDs",
      },
    },
    lastMessage: {
      type: LastMessageSchema,
      required: false,
      default: null,
    },
    unreadCounts: {
      type: Map,
      of: Number,
      default: {},
    },
  },
  {
    timestamps: true,
  }
);
module.exports = model("Conversation", ConversationSchema);
