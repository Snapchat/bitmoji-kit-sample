package com.snapchat.kit.bitmojisample.chat.model;

import android.support.annotation.DrawableRes;


public class ChatImageMessage implements ChatMessage {

    private final boolean mIsFromMe;
    private final int mDrawableResId;

    public ChatImageMessage(boolean isFromMe, @DrawableRes int drawableResId) {
        mIsFromMe = isFromMe;
        mDrawableResId = drawableResId;
    }

    public boolean isFromMe() {
        return mIsFromMe;
    }

    @DrawableRes
    public int getDrawableResId() {
        return mDrawableResId;
    }

    @Override
    public Type getType() {
        return Type.IMAGE;
    }
}
