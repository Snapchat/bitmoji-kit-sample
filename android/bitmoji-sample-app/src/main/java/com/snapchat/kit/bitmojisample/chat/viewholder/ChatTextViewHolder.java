package com.snapchat.kit.bitmojisample.chat.viewholder;

import android.graphics.Color;
import android.view.ViewGroup;
import android.widget.TextView;

import com.snapchat.kit.bitmojisample.R;


public class ChatTextViewHolder extends ChatViewHolder {

    private final TextView mTextView;

    public ChatTextViewHolder(ViewGroup root) {
        super(root);

        mTextView = root.findViewById(R.id.chat_text);
    }

    public void setText(String text) {
        mTextView.setText(text);
    }

    @Override
    public void setIsFromMe(boolean isFromMe) {
        super.setIsFromMe(isFromMe);

        if (isFromMe) {
            mTextView.setTextColor(Color.BLACK);
            mTextView.setBackgroundResource(R.drawable.chat_bubble_grey);
        } else {
            mTextView.setTextColor(Color.WHITE);
            mTextView.setBackgroundResource(R.drawable.chat_bubble_green);
        }
    }
}
