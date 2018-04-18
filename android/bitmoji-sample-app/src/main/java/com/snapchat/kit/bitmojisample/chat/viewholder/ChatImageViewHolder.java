package com.snapchat.kit.bitmojisample.chat.viewholder;

import android.content.Context;
import android.support.annotation.DrawableRes;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.snapchat.kit.bitmojisample.R;
import com.squareup.picasso.Callback;
import com.squareup.picasso.Picasso;


public class ChatImageViewHolder extends ChatViewHolder {

    private final Context mContext;
    private final View mImageContainer;
    private final ImageView mImageView;
    private final View mLoadingIndicator;

    public ChatImageViewHolder(Context context, ViewGroup root) {
        super(root);

        mContext = context;
        mImageContainer = root.findViewById(R.id.chat_image_container);
        mImageView = root.findViewById(R.id.chat_image);
        mLoadingIndicator = root.findViewById(R.id.chat_loading);
    }

    public void setImageUrl(String imageUrl) {
        mImageView.setImageDrawable(null);
        mLoadingIndicator.setVisibility(View.VISIBLE);
        Picasso.with(mContext)
                .load(imageUrl)
                .into(mImageView, new Callback() {
                    @Override
                    public void onSuccess() {
                        mLoadingIndicator.setVisibility(View.GONE);
                    }

                    @Override
                    public void onError() {

                    }
                });
    }

    public void setDrawable(@DrawableRes int drawableResId) {
        mLoadingIndicator.setVisibility(View.GONE);
        mImageView.setImageDrawable(mContext.getResources().getDrawable(drawableResId));
    }

    public void recycle() {
        Picasso.with(mContext).cancelRequest(mImageView);
    }
}
