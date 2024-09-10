package org.soltalk.soltalk_backend.domain.account.service;

import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.soltalk.soltalk_backend.domain.account.controller.AccountController;
import org.soltalk.soltalk_backend.domain.account.projection.SummaryAccount;
import org.soltalk.soltalk_backend.domain.account.repository.AccountRepository;
import org.soltalk.soltalk_backend.config.OpenApiUrls;
import org.soltalk.soltalk_backend.domain.user.entity.User;
import org.soltalk.soltalk_backend.domain.user.repository.UserRepository;
import org.soltalk.soltalk_backend.util.OpenApiUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class AccountService {

    private final AccountRepository accountRepository;
    private final UserRepository userRepository;
    private static final Logger logger = LoggerFactory.getLogger(AccountController.class.getSimpleName());

    public List<SummaryAccount> findActiveAccounts() {
        return accountRepository.findSummaryAccounts();
    }

    /**
     * 1원 인증 코드 전송
     * @param accountNo 계좌번호
     * @param userId 계좌 주인 사용자
     * @return 인증코드
     * @throws URISyntaxException
     */
    public String transferOneWon(String accountNo, int userId) throws URISyntaxException {
        logger.info("transferOneWon()...accountNo:{}, userId:{}", accountNo, userId);
        User user = userRepository.findByUserId(userId);
        String userKey = user.getUserKey();

        Map<String, String> header = OpenApiUtil.createHeaders(userKey, OpenApiUrls.OPEN_ACCOUNT_AUTH);

        Map<String, Object> request = new HashMap<>();
        request.put("Header", header);
        request.put("accountNo", accountNo);
        request.put("authText", "SOLTALK");

        ResponseEntity<String> response = OpenApiUtil.callApi(new URI(OpenApiUrls.ACCOUNT_AUTH_URL + OpenApiUrls.OPEN_ACCOUNT_AUTH), request);
        ObjectMapper objectMapper = new ObjectMapper();

        String transactionUniqueNo = "";
        try {
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            transactionUniqueNo = rootNode.path("REC").path("transactionUniqueNo").asText();
        } catch (Exception e) {
            throw new RuntimeException("err", e);
        }

        return getAuthCode(accountNo, userKey, transactionUniqueNo);
    }

    /**
     * 1원 인증 코드 확인
     * @param accountNo
     * @param userKey
     * @param transactionUniqueNo
     * @return
     * @throws URISyntaxException
     */
    public String getAuthCode(String accountNo, String userKey, String transactionUniqueNo) throws URISyntaxException {
        logger.info("transferOneWon()...accountNo:{}, userKey:{}, transactionUniqueNo:{}", accountNo, userKey, transactionUniqueNo);
        Map<String, String> header = OpenApiUtil.createHeaders(userKey, OpenApiUrls.INQUIRE_TRANSACTION_HISTORY);
        Map<String, Object> request = new HashMap<>();
        request.put("Header", header);
        request.put("accountNo", accountNo);
        request.put("transactionUniqueNo", transactionUniqueNo);

        ResponseEntity<String> response = OpenApiUtil.callApi(new URI(OpenApiUrls.DEMAND_DEPOSIT_URL + OpenApiUrls.INQUIRE_TRANSACTION_HISTORY), request);
        ObjectMapper objectMapper = new ObjectMapper();
        logger.error("response:{}", response);
        try {
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            String summary = rootNode.path("REC").path("transactionSummary").asText();
            String code = summary.substring(8);
            logger.error("authCode:{} ", code);
            return code;
        } catch (Exception e) {
            throw new RuntimeException("err", e);
        }
    }


    // 1원 검증
    public String verifyOneWon(String accountNo, String authCode, int userId) throws URISyntaxException {
        logger.info("verifyOneWon()...accountNo:{}, authCode:{}, userId:{}", accountNo, authCode, userId);
        User user = userRepository.findByUserId(userId);
        Map<String, String> header = OpenApiUtil.createHeaders(user.getUserKey(), OpenApiUrls.CHECK_ACCOUNT_AUTH);

        Map<String, Object> request = new HashMap<>();
        request.put("Header", header);
        request.put("accountNo", accountNo);
        request.put("authText", "SOLTALK");
        request.put("authCode", authCode);

        ResponseEntity<String> response = OpenApiUtil.callApi(new URI(OpenApiUrls.ACCOUNT_AUTH_URL + OpenApiUrls.CHECK_ACCOUNT_AUTH), request);
        ObjectMapper objectMapper = new ObjectMapper();
        try {
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            String status = rootNode.path("REC").path("status").asText(); //SUCCESS
        } catch (Exception e) {
            throw new RuntimeException("err", e);
        }
        return response.getBody();
    }



}