package org.soltalk.soltalk_backend.domain.financial.service;

import java.net.URISyntaxException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.soltalk.soltalk_backend.domain.account.projection.SummaryAccount;
import org.soltalk.soltalk_backend.domain.account.service.AccountService;
import org.soltalk.soltalk_backend.domain.financial.dto.TransactionSummaryResponse;
import org.soltalk.soltalk_backend.domain.financial.entity.DailyFinancialSummary;
import org.soltalk.soltalk_backend.domain.financial.repository.FinancialSummaryRepository;
import org.soltalk.soltalk_backend.util.OpenApiUtil;
import org.soltalk.soltalk_backend.util.TransactionCategoryClassifier;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import lombok.AllArgsConstructor;

/**
 * 금융 정보 생성 및 저장
 */
@Service
@AllArgsConstructor
public class FinancialSummaryProcessor {
    
    private AccountService accountService;
    private DemandDepositCollector demandDepositCollector;
    private SavingsCollector savingsCollector;
    private FinancialSummaryRepository summaryRepository;
	private static final Logger logger = LoggerFactory.getLogger(FinancialSummaryProcessor.class.getSimpleName());
    
	/**
	 * 자정마다 모든 활성화 된 계좌의 전날 지출/수익/저축 내역을 받아 summary
	 * 시스템 시간 고려해서 5분에 실행 
	 * @throws URISyntaxException
	 */
    @Scheduled(cron = "0 5 0 * * *")
	public void fetchAndStoreFinancialData() throws URISyntaxException {
		logger.info("Scheduler : fetchAndStoreFinancialData() 시작");
	    String yesterday = LocalDate.now().minusDays(1).format(OpenApiUtil.DATE_FORMATTER);//1일전
	    
	    List<SummaryAccount> userAccounts = accountService.findActiveAccounts();
	    for(SummaryAccount userAccount : userAccounts) {
	    	if(userAccount.getAccountType() == 1) { //저축
	    		fetchSavingsData(userAccount, yesterday); // 저축 계산
	    		
	    	}else if(userAccount.getAccountType() == 2) { //입출금
	    		fetchTransactionData(userAccount, yesterday); // 입출금 계좌 지출/수익 계산
	    	}
	    }
	}
	
	/**
	 * 입출금 계좌 내역 처리
	 * 
	 * @param userAccount
	 * @param date
	 * @throws URISyntaxException
	 */
	private void fetchTransactionData(SummaryAccount userAccount, String date) throws URISyntaxException {
		logger.info("fetchTransactionData()...userAccount:{}, date:{}", userAccount.toString(), date);
    	int userNo = userAccount.getUserNo();
    	Map<String, List<TransactionSummaryResponse>> transactionMap = demandDepositCollector.fetchTransactions(userAccount, date);// 거래 내역 받아오기
    	logger.error("transactionMap:{}", transactionMap.toString());
		categorizeSpending(userNo,  transactionMap.get("spendingList")); // 지출 카테고리 분류
    	categorizeIncome(userNo,  transactionMap.get("incomeList")); // 수입 카테고리
	}
	
	/**
	 * 저축 계좌 내역 처리 
	 * 
	 * @param userAccount
	 * @param date
	 * @throws URISyntaxException
	 */
	private void fetchSavingsData(SummaryAccount userAccount, String date) throws URISyntaxException {
		logger.info("fetchSavingsData()...userAccount:{}, date:{}", userAccount.toString(), date);
		int amount = savingsCollector.fetchSavings(userAccount, date);// 저축 금액 받기
		if(amount != 0) {
			createSummary(userAccount.getUserNo(), amount);
		}
	}
	
	
	/**
	 * 카테고리별 지출금액 분류
	 * @param userNo 지출 사용자 일련번호
	 * @param transactions 어제 지출 내역(상호명 포함)
	 */
	private void categorizeSpending(int userNo, List<TransactionSummaryResponse> transactions) {
		logger.info("categorizeSpending()...userNo:{}, transactions:{}", userNo, transactions.toString());
	    // 카테고리, 카테고리 지출 금액합
		Map<String, Integer> categoryTotals = new HashMap<>();

	    // 거래 내역별 카테고리 분류, 카테고리 별 금액 합산
	    for (TransactionSummaryResponse transaction : transactions) {
	        String category = TransactionCategoryClassifier.spendingClassify(transaction.getTransactionSummary());
	        int amount = transaction.getTransactionBalance();
	        
	        categoryTotals.put(category, categoryTotals.getOrDefault(category, 0) + amount);
	    }
	    // 2 지출
	    createSummaries(userNo, categoryTotals, 0);
	}
	
	
	/**
	 * 당근 수익 분류
	 * @param userNo 사용자 일련번호
	 * @param transactions 어제 수익 내역
	 */
	private void categorizeIncome(int userNo, List<TransactionSummaryResponse> transactions) {
		logger.info("categorizeIncome()...userNo:{}, transactions:{}", userNo, transactions.toString());
		int income = 0;
	    // 중고 수익만 체크
	    for (TransactionSummaryResponse transaction : transactions) {
	        String category = TransactionCategoryClassifier.incomeClassify(transaction.getTransactionSummary());
	        if(category.equals("당근수익")) income += transaction.getTransactionBalance();
	    }
	    // 3 수익
	    createSummaries(userNo, null, income);
	}
	
	/**
	 * 
	 * @param userId 사용자 번호
	 * @param spendingCategoryTotals 카테고리별 총 사용금액
	 * @param amount 사용금액이 아닐 때 > 수익 금액
	 */
	private void createSummaries(int userId, Map<String, Integer> spendingCategoryTotals, int amount) {
		logger.info("createSummaries()...userId:{}, spendingCategoryTotals:{}, amount:{}", userId, spendingCategoryTotals.toString(), amount);
	    // 카테고리별 요약 정보를 DailyFinancialSummary 객체로 변환
	    List<DailyFinancialSummary> summaries = new ArrayList<>();
	    if(spendingCategoryTotals == null) { // income
	    	addSummary(summaries, userId, 3, "당근수익", amount);
	    }else { //spending
	    	for (Map.Entry<String, Integer> entry : spendingCategoryTotals.entrySet()) {
	    		if(entry.getValue() == 0) {
	    			continue;
	    		}
	    		addSummary(summaries, userId, 2, entry.getKey(), entry.getValue());
	    	}
	    }
	    storeSummaries(summaries);
	}
	
	/**
	 * 
	 * @param userId
	 * @param amount
	 */
	private void createSummary(int userId, int amount) {
		logger.info("createSummary()...userId:{}, amount:{}", userId, amount);
		DailyFinancialSummary summary = DailyFinancialSummary.builder()
				.userId(userId)
				.financialDate(LocalDate.now().minusDays(1))
				.financialType(1)
				.category(null)
				.totalAmount(amount)
				.createdAt(LocalDateTime.now())
				.updatedAt(LocalDateTime.now())
				.build();
		storeSummary(summary);
	}
	
	/**
	 * 
	 * @param summaries
	 * @param userId
	 * @param financialType
	 * @param category
	 * @param amount
	 */
	private void addSummary(List<DailyFinancialSummary> summaries, int userId, int financialType, String category, int amount) {
		logger.info("addSummary()...summaries:{}, userId:{}, financialType:{}, category:{}, amount:{}", summaries.toString(), userId, financialType, category, amount);
		DailyFinancialSummary summary = DailyFinancialSummary.builder()
				.userId(userId)
				.financialDate(LocalDate.now().minusDays(1))
				.financialType(financialType)
				.category(category)
				.totalAmount(amount)
				.createdAt(LocalDateTime.now())
				.updatedAt(LocalDateTime.now())
				.build();
		summaries.add(summary);
	}


	// add summaries data to daily_financial_summary
	private void storeSummaries(List<DailyFinancialSummary> summaries) {
		logger.info("storeSummaries()...summaries:{}", summaries.toArray());
        summaryRepository.saveAll(summaries);
    }
	
	// add summary data to daily_financial_summary
	private void storeSummary(DailyFinancialSummary summary) {
        summaryRepository.save(summary);
    }
}