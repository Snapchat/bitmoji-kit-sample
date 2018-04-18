package com.snapchat.kit.bitmojisample.chat.viewholder;

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

import com.snapchat.kit.bitmojisample.R;


public abstract class ChatViewHolder extends RecyclerView.ViewHolder {

    private final ViewGroup mRoot;
    private final View mSpacer;

    private boolean mIsFromMe = true;

    public ChatViewHolder(ViewGroup root) {
        super(root);

        mRoot = root;
        mSpacer = root.findViewById(R.id.chat_spacer);
    }

    public void setIsFromMe(boolean isFromMe) {
        if (mSpacer == null || isFromMe == mIsFromMe) {
            return;
        }

        if (isFromMe) {
            mRoot.removeView(mSpacer);
            mRoot.addView(mSpacer, 0);
        } else {
            mSpacer.bringToFront();
        }

        mIsFromMe = isFromMe;
    }
}
