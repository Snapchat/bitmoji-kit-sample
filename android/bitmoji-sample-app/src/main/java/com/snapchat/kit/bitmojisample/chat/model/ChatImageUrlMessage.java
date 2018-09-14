package com.snapchat.kit.bitmojisample.chat.model;

import android.graphics.drawable.Drawable;

import java.lang.ref.WeakReference;

public class ChatImageUrlMessage implements ChatMessage {

    private final boolean mIsFromMe;
    private final String mImageUrl;
    private final WeakReference<Drawable> mPreviewDrawable;

    public ChatImageUrlMessage(boolean isFromMe, String imageUrl, Drawable previewDrawable) {
        mIsFromMe = isFromMe;
        mImageUrl = imageUrl;
        mPreviewDrawable = new WeakReference<>(previewDrawable);
    }

    public boolean isFromMe() {
        return mIsFromMe;
    }

    public String getImageUrl() {
        return mImageUrl;
    }

    public Drawable getPreview() {
        return mPreviewDrawable.get();
    }

    @Override
    public Type getType() {
        return Type.IMAGE;
    }
}

