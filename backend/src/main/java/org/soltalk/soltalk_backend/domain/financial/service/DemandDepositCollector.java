package org.soltalk.soltalk_backend.domain.financial.service;

import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.soltalk.soltalk_backend.domain.account.projection.SummaryAccount;
import org.soltalk.soltalk_backend.domain.financial.dto.TransactionSummaryResponse;
import org.soltalk.soltalk_backend.domain.financial.projection.UserCategory;
import org.soltalk.soltalk_backend.config.OpenApiUrls;
import org.soltalk.soltalk_backend.util.OpenApiUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * 계좌 거래 내역 수집 및 처리 
 */
@Service
public class DemandDepositCollector {
	
	private static final Logger logger = LoggerFactory.getLogger(DemandDepositCollector.class);	
	
	/**
	 * 해당 계좌의 입출금 거래 내역 불러오기
	 * 
	 * @param accountNo 조회할 계좌번호
	 * @param date 조회할 날짜
	 * @return 입출금 거래 내역
	 * @throws URISyntaxException
	 */
	public Map<String, List<TransactionSummaryResponse>> fetchTransactions(SummaryAccount accountNo, String date) throws URISyntaxException {
        logger.info("fetchTransactions()...accountNo:{}, date:{}", accountNo, date);
        Map<String, String> headerMap = OpenApiUtil.createHeaders(accountNo.getUserKey(), OpenApiUrls.INQUIRE_TRANSACTION_HISTORY_LIST);
        Map<String, Object> requestMap = OpenApiUtil.createTransactionHistoryRequestData(accountNo.getAccountNo(), date, "A", headerMap);

        ResponseEntity<String> response = OpenApiUtil.callApi(new URI(OpenApiUrls.DEMAND_DEPOSIT_URL + OpenApiUrls.INQUIRE_TRANSACTION_HISTORY_LIST), requestMap);
        logger.error("inquireTransactionHistoryList:{}", response.toString());
        ObjectMapper objectMapper = new ObjectMapper();
        
        try {
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            JsonNode listNode = rootNode.path("REC").path("list");
            return parseTransactionList(listNode);
        } catch (Exception e) {
        	logger.error("계좌 거래 내역 추출 중 오류 발생");
            throw new RuntimeException("계좌 거래 내역 추출 중 오류 발생", e);
        }

    }

	
    /**
	 * 응답데이터를 parsing 하여 지출내역/수익내역을 반환
	 * @param listNode
	 * @return
	 */
    private Map<String, List<TransactionSummaryResponse>> parseTransactionList(JsonNode listNode) {
        logger.info("parseTransactionList()...JsonNode:{}", listNode);
    	Map<String, List<TransactionSummaryResponse>> transactionMap = new HashMap<>();
        List<TransactionSummaryResponse> spendingList = new ArrayList<TransactionSummaryResponse>();
        List<TransactionSummaryResponse> incomeList = new ArrayList<TransactionSummaryResponse>();
        
        if (listNode.isArray()) {
            for (JsonNode item : listNode) {
                int transactionBalance = item.path("transactionBalance").asInt();
                String transactionSummary = item.path("transactionSummary").asText();
                String transactionType = item.path("transactionType").asText(); //1입금 2출금
                TransactionSummaryResponse transaction = TransactionSummaryResponse.builder()
                        .transactionBalance(transactionBalance)
                        .transactionSummary(transactionSummary)
                        .build();
                logger.error("TransactionDTO:{}", transaction.toString());
                if(transactionType.equals("1")) spendingList.add(transaction);
                else incomeList.add(transaction);
            }
        }
        
        transactionMap.put("spendingList", spendingList);
        transactionMap.put("incomeList", incomeList);
        
        return transactionMap;
    }
    
    
    /**
	 * 한달간의 지출 내역 받아오기
	 * @param categoryDTO
	 * @throws URISyntaxException
	 */
	public List<TransactionSummaryResponse> fetchTransactionsForMonth(UserCategory categoryDTO) throws URISyntaxException  {
        logger.info("fetchTransactionsForMonth()...UserCategoryDTO:{}", categoryDTO.toString());
		String startDate = LocalDate.now().minusDays(30).format(OpenApiUtil.DATE_FORMATTER); //30일전부터
		String endDate = LocalDate.now().minusDays(1).format(OpenApiUtil.DATE_FORMATTER); //어제까지

		Map<String, String> headerMap = OpenApiUtil.createHeaders(categoryDTO.getUserKey(), OpenApiUrls.INQUIRE_TRANSACTION_HISTORY_LIST);
        Map<String, Object> requestMap = OpenApiUtil.createTransactionHistoryRequestDataForMonth(categoryDTO.getAccountNo(), startDate, endDate, "D", headerMap);

        ResponseEntity<String> response = OpenApiUtil.callApi(new URI(OpenApiUrls.DEMAND_DEPOSIT_URL + OpenApiUrls.INQUIRE_TRANSACTION_HISTORY_LIST), requestMap);
        logger.error("inquireTransactionHistoryList:{}", response.toString());
        ObjectMapper objectMapper = new ObjectMapper();
        
        try {
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            JsonNode listNode = rootNode.path("REC").path("list");
            return parseTransactionListForMonth(listNode);
        } catch (Exception e) {
        	logger.error("계좌 거래 내역 추출 중 오류 발생");
            throw new RuntimeException("계좌 거래 내역 추출 중 오류 발생", e);
        }
	}
	
	/**
	 * 응답데이터를 parsing 하여 지출내역 반환
	 * @param listNode
	 * @return
	 */
    private List<TransactionSummaryResponse> parseTransactionListForMonth(JsonNode listNode) {
        logger.info("parseTransactionListForMonth()...JsonNode:{}", listNode);
        List<TransactionSummaryResponse> transactions = new ArrayList<>();
        
        if (listNode.isArray()) {
            for (JsonNode item : listNode) {
                TransactionSummaryResponse transaction = TransactionSummaryResponse.builder()
                        .transactionBalance(item.path("transactionBalance").asInt()) //금액
                        .transactionSummary(item.path("transactionSummary").asText()) //지출처
                        .build();
                transactions.add(transaction);
            }
        }
        return transactions;
    }
}