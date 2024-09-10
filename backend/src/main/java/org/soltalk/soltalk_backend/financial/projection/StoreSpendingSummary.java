package org.soltalk.soltalk_backend.financial.projection;

public interface StoreSpendingSummary {
	String getStoreName(); // 지출처
	int getVisitCount(); //  한달간 지출처 방문 횟수
	int getTotalAmount(); // 한달간 지출처에서 소비한 금액
}
