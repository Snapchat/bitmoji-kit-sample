package com.snapchat.kit.bitmojisample;

import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewTreeObserver;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.snapchat.kit.sdk.SnapKit;
import com.snapchat.kit.sdk.SnapLogin;
import com.snapchat.kit.sdk.bitmoji.OnBitmojiSearchFocusChangeListener;
import com.snapchat.kit.sdk.bitmoji.OnBitmojiSelectedListener;
import com.snapchat.kit.sdk.bitmoji.ui.BitmojiFragment;
import com.snapchat.kit.sdk.bitmoji.ui.BitmojiIconFragment;
import com.snapchat.kit.bitmojisample.chat.ChatAdapter;
import com.snapchat.kit.bitmojisample.chat.model.ChatImageMessage;
import com.snapchat.kit.bitmojisample.chat.model.ChatImageUrlMessage;
import com.snapchat.kit.bitmojisample.chat.model.ChatMessage;
import com.snapchat.kit.bitmojisample.chat.model.ChatTextMessage;
import com.snapchat.kit.sdk.core.controller.LoginStateController;
import com.snapchat.kit.sdk.login.models.UserDataResponse;
import com.snapchat.kit.sdk.login.networking.FetchUserDataCallback;


public class TestAppActivity extends FragmentActivity implements
        OnBitmojiSelectedListener,
        OnBitmojiSearchFocusChangeListener,
        TextView.OnEditorActionListener,
        ViewTreeObserver.OnGlobalLayoutListener,
        LoginStateController.OnLoginStateChangedListener {

    private static final float BITMOJI_CONTAINER_FOCUS_WEIGHT = 9.0f;
    private static final String EXTERNAL_ID_QUERY = "{me{externalId}}";

    private final ChatAdapter mAdapter = new ChatAdapter();

    private View mContentView;
    private View mBitmojiContainer;
    private View mFriendmojiToggle;
    private EditText mTextField;
    private RecyclerView mChatView;

    private int mBitmojiContainerHeight;
    private int mBaseRootViewHeightDiff = 0;
    private int mBitmojisSent = 0;
    private boolean mIsBitmojiVisible = true;
    private boolean mShowingFriendmoji = false;
    private String mMyExternalId;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_test_app);

        final Button sendButton = findViewById(R.id.send_button);

        mContentView = findViewById(R.id.content_view);
        mBitmojiContainer = findViewById(R.id.sdk_container);
        mTextField = findViewById(R.id.input_field);
        mFriendmojiToggle = findViewById(R.id.friendmoji_toggle);
        mChatView = findViewById(R.id.chat);
        mBitmojiContainerHeight = getResources().getDimensionPixelSize(R.dimen.bitmoji_container_height);

        mAdapter.setHasStableIds(true);
        mChatView.setLayoutManager(new LinearLayoutManager(
                this, LinearLayoutManager.VERTICAL, true /* reverseLayout*/));
        mChatView.setAdapter(mAdapter);
        mTextField.setOnEditorActionListener(this);

        mTextField.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                if (hasFocus) {
                    setBitmojiVisible(true);
                }
            }
        });
        mTextField.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                // no-op
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                // no-op
            }

            @Override
            public void afterTextChanged(Editable s) {
                sendButton.setEnabled(s.length() > 0);
            }
        });
        mFriendmojiToggle.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.sdk_container);
                if (fragment instanceof BitmojiFragment) {
                    ((BitmojiFragment) fragment).setFriend(mShowingFriendmoji ? null : mMyExternalId);
                }
                mShowingFriendmoji = !mShowingFriendmoji;
            }
        });
        sendButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                sendText();
            }
        });
        findViewById(R.id.unlink_button).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                SnapKit.unlink(TestAppActivity.this);
            }
        });
        findViewById(R.id.bitmoji_button).setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (getCurrentFocus() != mTextField) {
                    setBitmojiVisible(!mIsBitmojiVisible);
                }
                defocusInput();
            }
        });

        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE);
        SnapLogin.getLoginStateController(this).addOnLoginStateChangedListener(this);
        mContentView.getViewTreeObserver().addOnGlobalLayoutListener(this);
        mTextField.requestFocus();

        getSupportFragmentManager().beginTransaction()
                .replace(R.id.sdk_container, new BitmojiFragment())
                .commit();
        getSupportFragmentManager().beginTransaction()
                .replace(R.id.bitmoji_button, new BitmojiIconFragment())
                .commit();

        if (SnapLogin.isUserLoggedIn(this)) {
            loadExternalId();
        }
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent event) {
        Rect hitRect = new Rect();

        mChatView.getHitRect(hitRect);

        if (hitRect.contains((int) event.getX(), (int) event.getY())) {
            defocusInput();
            setBitmojiVisible(false);
        }
        return super.dispatchTouchEvent(event);
    }

    @Override
    public void onGlobalLayout() {
        int heightDiff = getRootViewHeightDiff(mContentView);

        if (heightDiff > getResources().getDimensionPixelSize(R.dimen.min_keyboard_height)) {
            LinearLayout.LayoutParams params =
                    (LinearLayout.LayoutParams) mBitmojiContainer.getLayoutParams();

            mContentView.getViewTreeObserver().removeOnGlobalLayoutListener(this);

            params.height = heightDiff - mBaseRootViewHeightDiff;
            mBitmojiContainer.setLayoutParams(params);

            getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING);
        } else {
            mBaseRootViewHeightDiff = heightDiff;
        }
    }

    @Override
    public void onBitmojiSelected(String imageUrl, Drawable previewDrawable) {
        handleBitmojiSend(imageUrl, previewDrawable);
    }

    @Override
    public void onBitmojiSearchFocusChange(boolean hasFocus) {
        getWindow().setSoftInputMode(hasFocus
                ? WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE
                : WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING);

        LinearLayout.LayoutParams params =
                (LinearLayout.LayoutParams) mBitmojiContainer.getLayoutParams();

        // Set container height to 90% of available space when focused
        params.weight = hasFocus ? BITMOJI_CONTAINER_FOCUS_WEIGHT : 0;
        params.height = hasFocus ? 0 : mBitmojiContainerHeight;

        mBitmojiContainer.setLayoutParams(params);
    }

    @Override
    public void onLoginSucceeded() {
        loadExternalId();
    }

    @Override
    public void onLoginFailed() {
        // no-op
    }

    @Override
    public void onLogout() {
        // no-op
    }

    @Override
    public boolean onEditorAction(TextView textView, int actionId, KeyEvent event) {
        if (actionId == EditorInfo.IME_ACTION_SEND) {
            sendText();
            textView.requestFocus();
            return true;
        }
        return false;
    }

    private void loadExternalId() {
        SnapLogin.fetchUserData(this, EXTERNAL_ID_QUERY, null, new FetchUserDataCallback() {
            @Override
            public void onSuccess(@Nullable UserDataResponse userDataResponse) {
                if (userDataResponse == null || userDataResponse.hasError()) {
                    return;
                }
                mMyExternalId = userDataResponse.getData().getMe().getExternalId();
                mFriendmojiToggle.setVisibility(View.VISIBLE);
            }

            @Override
            public void onFailure(boolean isNetworkError, int statusCode) {
                // handle error
            }
        });
    }

    private void setBitmojiVisible(boolean isBitmojiVisible) {
        mIsBitmojiVisible = isBitmojiVisible;
        mBitmojiContainer.setVisibility(isBitmojiVisible ? View.VISIBLE : View.GONE);
    }

    private void defocusInput() {
        View currentFocus = getCurrentFocus();

        if (currentFocus == null ) {
            return;
        }

        InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(currentFocus.getWindowToken(), 0);
        currentFocus.clearFocus();
    }

    private void handleBitmojiSend(String imageUrl, Drawable previewDrawable) {
        sendMessage(new ChatImageUrlMessage(true /*isFromMe*/, imageUrl, previewDrawable));

        if (mBitmojisSent == 0) {
            sendDelayedMessage(new ChatTextMessage(false /*isFromMe*/, "Woah, nice Bitmoji!"), 500);
            sendDelayedMessage(new ChatImageMessage(false /*isFromMe*/, R.drawable.looking_good),1000);
        } else if (mBitmojisSent == 1) {
            sendDelayedMessage(new ChatImageMessage(false /*isFromMe*/, R.drawable.party_time),1000);
        } else if (mBitmojisSent == 2) {
            sendDelayedMessage(new ChatTextMessage(false /*isFromMe*/, "lol"),500);
        } else if (mBitmojisSent == 14) {
            sendDelayedMessage(new ChatImageMessage(false /*isFromMe*/, R.drawable.chill), 1000);
        }

        mBitmojisSent++;
    }

    private void sendText() {
        String text = mTextField.getText().toString();
        if (TextUtils.isEmpty(text)) {
            return;
        }

        sendMessage(new ChatTextMessage(true /*isFromMe*/, text));
        mTextField.setText("");
    }

    private void sendMessage(ChatMessage message) {
        mAdapter.add(message);
        mChatView.scrollToPosition(0);
    }

    private void sendDelayedMessage(final ChatMessage message, long delayMs) {
        mContentView.postDelayed(new Runnable() {
            @Override
            public void run() {
                sendMessage(message);
            }
        }, delayMs);
    }

    private static int getRootViewHeightDiff(View view) {
        return view.getRootView().getHeight() - view.getHeight();
    }
}
