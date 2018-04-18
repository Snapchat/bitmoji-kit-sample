package com.snapchat.kit.bitmojisample.chat.model;


public interface ChatMessage {

    enum Type {
        IMAGE,
        TEXT
    }

    boolean isFromMe();
    Type getType();
}
