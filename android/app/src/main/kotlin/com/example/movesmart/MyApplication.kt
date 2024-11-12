package com.example.movesmart

import android.app.Application
import com.kakao.sdk.common.KakaoSdk

class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // 카카오 SDK 초기화
        KakaoSdk.init(this, "a185a267072df6495590e209e7af148b") // 실제 앱 키로 변경
    }
}
