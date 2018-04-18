package com.snapchat.kit.bitmojisample.chat.model;


public class ChatTextMessage implements ChatMessage {

    private final boolean mIsFromMe;
    private final String mText;

    public ChatTextMessage(boolean isFromMe, String text) {
        mIsFromMe = isFromMe;
        mText = text;
    }

    public boolean isFromMe() {
        return mIsFromMe;
    }

    public String getText() {
        return mText;
    }

    @Override
    public Type getType() {
        return Type.TEXT;
    }
}
