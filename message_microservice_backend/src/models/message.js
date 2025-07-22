const mongoose = require("mongoose");
const { Schema, model, Types } = mongoose;

const MessageSchema = new Schema(
  {
    conversationId: { type: Types.ObjectId, ref: "Conversation", required: true },
    senderId: { type: Types.ObjectId, ref: "User", required: true },
    receiverId: { type: Types.ObjectId, ref: "User", required: true },
    type: {
      type: String,
      enum: ['TEXT', 'IMAGE'],
      default: 'TEXT',
    },
    content: {
      type: String,
      trim: true,
      required: function () { return this.type === 'TEXT'; },
    },
    mediaUrl: {
      type: String,
      required: function () { return this.type === 'IMAGE'; },
    },
    read: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = model("Message", MessageSchema);
