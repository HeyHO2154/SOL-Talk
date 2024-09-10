package org.soltalk.soltalk_backend.config;

public class OpenApiUrls {

	private static final String COMMON_URL = "http://localhost:9090/soltalk/openapi/v1/";

	//// 사용자 계정 생성
	public static final String CREATE_USER_KEY = COMMON_URL + "member/";

	//// 입출금 URL 공통 
	public static final String DEMAND_DEPOSIT_URL = COMMON_URL + "demandDeposit/";
	//// 적금 URL 공통 
	public static final String SAVINGS_URL = COMMON_URL + "savings/";
	//// 1원 인증 URL 공통
	public static final String ACCOUNT_AUTH_URL = COMMON_URL + "accountAuth/";
	
	//// 입출금 계좌
	// 예금주 조회
	public static final String INQUIRE_DEMAND_DEPOSIT_ACCOUNT_HOLDER_NAME = "inquireDemandDepositAccountHolderName";
	// 계좌 잔액 조회
	public static final String INQUIRE_DEMAND_DEPOSIT_ACCOUNT_BALANCE = "inquireDemandDepositAccountBalance";
	// 계좌 출금
	public static final String UPDATE_DEMAND_DEPOSIT_ACCOUNT_WITHDRAWAL = "updateDemandDepositAccountWithdrawal";
	// 계좌 입금
	public static final String UPDATE_DEMAND_DEPOSIT_ACCOUNT_DEPOSIT = "updateDemandDepositAccountDeposit";
	// 계좌 이체
	public static final String UPDATE_DEMAND_DEPOSIT_ACCOUNT_TRANSFER = "updateDemandDepositAccountTransfer";
	// 계좌 거래 내역 조회
	public static final String INQUIRE_TRANSACTION_HISTORY_LIST = "inquireTransactionHistoryList";
	// 계좌 거래 내역 조회(단건)
	public static final String INQUIRE_TRANSACTION_HISTORY = "inquireTransactionHistory";

	//// 적금 계좌
	// 적금 납입 회차 조회
	public static final String INQUIRE_PAYMENT = "inquirePayment";
	
	// 1원 인증
	// 1원 송금
	public static final String OPEN_ACCOUNT_AUTH = "openAccountAuth";
	// 1원 검증
	public static final String CHECK_ACCOUNT_AUTH = "checkAuthCode";
}
