package com.snapchat.kit.bitmojisample.chat.model;


public class ChatImageUrlMessage implements ChatMessage {

    private final boolean mIsFromMe;
    private final String mImageUrl;

    public ChatImageUrlMessage(boolean isFromMe, String imageUrl) {
        mIsFromMe = isFromMe;
        mImageUrl = imageUrl;
    }

    public boolean isFromMe() {
        return mIsFromMe;
    }

    public String getImageUrl() {
        return mImageUrl;
    }

    @Override
    public Type getType() {
        return Type.IMAGE;
    }
}
