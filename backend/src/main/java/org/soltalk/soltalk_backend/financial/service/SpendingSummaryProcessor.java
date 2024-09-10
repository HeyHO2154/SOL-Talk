package org.soltalk.soltalk_backend.financial.service;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.soltalk.soltalk_backend.financial.dto.StoreSpendingSummaryResponse;
import org.soltalk.soltalk_backend.financial.dto.TransactionSummaryResponse;
import org.soltalk.soltalk_backend.financial.projection.StoreSpendingSummary;
import org.soltalk.soltalk_backend.financial.projection.UserCategory;
import org.soltalk.soltalk_backend.util.TransactionCategoryClassifier;
import org.springframework.stereotype.Service;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class SpendingSummaryProcessor {
	
	private final DemandDepositCollector demandDepositCollector;
	private static final Logger logger = LoggerFactory.getLogger(SpendingSummaryProcessor.class.getSimpleName());
	
	/**
	 * // 특정 카테고리의 지출처별 가게별 방문 정보 반환
	 * @param categoryDTO
	 * @return 
	 * @throws URISyntaxException
	 */
	public List<StoreSpendingSummaryResponse> fetchTransactionDataForMonth(UserCategory categoryDTO) throws URISyntaxException {
		logger.info("fetchTransactionDataForMonth()...categoryDTO:{}", categoryDTO);
		// 한달 간의 지출 내역을 받아옴
		List<TransactionSummaryResponse> transactions = demandDepositCollector.fetchTransactionsForMonth(categoryDTO);
		return processSpendingStoreByCategory(categoryDTO.getCategory(), transactions);
	}
	
	/*private String category; // 지출 카테고리
	private String storeName; // 지출처
	private int visitCount; //  한달간 지출처 방문 횟수
	private int totalAmount; // 한달간 지출처에서 소비한 금액
	 */
	
	/**
	 * 가게별 소비 정보 
	 * @param category
	 * @param transactions
	 * @return
	 */
	private List<StoreSpendingSummaryResponse> processSpendingStoreByCategory(String category, List<TransactionSummaryResponse> transactions) {
		logger.info("processSpendingStoreByCategory()...category:{}, transactions:{}", category, transactions);
		List<StoreSpendingSummaryResponse> visitedStores = new ArrayList<>();
		// 지출처, 지출정보
		Map<String, StoreSpendingSummaryResponse> map = new HashMap<>();
		for(TransactionSummaryResponse transaction : transactions) {
			// 이 지출 내역이 카테고리에 포함 돼
			String storeName = transaction.getTransactionSummary();
			int amount = transaction.getTransactionBalance();
			if(TransactionCategoryClassifier.isCategory(storeName, category)) {
				if(!map.containsKey(storeName)) {
					map.put(storeName, new StoreSpendingSummaryResponse(storeName, 1, amount));
				}else {
					StoreSpendingSummaryResponse store = map.get(storeName);
					store.setVisitCount(store.getVisitCount()+1);
					store.setTotalAmount(store.getTotalAmount() + amount);
				}
			}
		}
		
		visitedStores.addAll(map.values());
		// 지출이 큰 순으로 정렬
		Collections.sort(visitedStores, (store1, store2) -> store2.getTotalAmount() - store1.getTotalAmount());
		
		return visitedStores;
	}
	
	/**
	 * 키워드별 소비 정리
	 * // 특정 카테고리의 가장 지출이 많은 키워드 반환
	 * @param categoryDTO
	 * @return 
	 * @throws URISyntaxException
	 */
	public String getKeywordWithCategoryForMonth(UserCategory categoryDTO) throws URISyntaxException {
		logger.info("getKeywordWithCategoryForMonth()...categoryDTO:{}", categoryDTO);
		// 한달 간의 저축 내역을 받아옴
		List<TransactionSummaryResponse> transactions = demandDepositCollector.fetchTransactionsForMonth(categoryDTO);
		return processSpendingKeywordByCategory(categoryDTO.getCategory(), transactions);
	}
	
	/**
	 * 키워드별 소비 정보 
	 * @param category
	 * @param transactions
	 * @return
	 */
	private String processSpendingKeywordByCategory(String category, List<TransactionSummaryResponse> transactions) {
		logger.info("processSpendingKeywordByCategory()...category:{}, transactions:{}", category, transactions);
		List<StoreSpendingSummaryResponse> list = new ArrayList<>();
		// 지출처, 지출정보
		Map<String, StoreSpendingSummaryResponse> map = new HashMap<>();
		// 지출처, 지출정보
		for(TransactionSummaryResponse transaction : transactions) {
			String storeName = transaction.getTransactionSummary();
			int amount = transaction.getTransactionBalance();
			String keyword = TransactionCategoryClassifier.keyword(storeName, category);
			// 이 지출 내역이 카테고리에 포함 돼
			if(keyword != null) {
				if(!map.containsKey(keyword)) {
					map.put(keyword, StoreSpendingSummaryResponse.builder()
										.storeName(keyword) //키워드로 써먹음
										.totalAmount(amount)
										.build()); 
				} else {
					StoreSpendingSummaryResponse store = map.get(keyword);
					store.setTotalAmount(store.getTotalAmount()+amount);
				}
			}
		}
		
		list.addAll(map.values());
		// 지출이 큰 순으로 정렬
		Collections.sort(list, (store1, store2) -> store2.getTotalAmount() - store1.getTotalAmount());
		if(list.isEmpty()) {
			return null;
		}
		
		StoreSpendingSummary store = list.get(0);
		return store.getStoreName(); //키워드
	}
}
