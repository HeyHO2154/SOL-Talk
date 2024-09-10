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
import org.soltalk.soltalk_backend.domain.user.entity.User;
import org.soltalk.soltalk_backend.util.OpenApiUrls;
import org.soltalk.soltalk_backend.util.OpenApiUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@AllArgsConstructor
public class AccountService {

    private final AccountRepository accountRepository;
    private static final Logger logger = LoggerFactory.getLogger(AccountController.class.getSimpleName());

    public List<SummaryAccount> findActiveAccounts() {
        return accountRepository.findSummaryAccounts();
    }

    public String transferOneWon(String accountNo, String email) throws URISyntaxException {
        logger.info("transferOneWon()...accountNo:{}, email:{}", accountNo, email);
        LocalDateTime now = LocalDateTime.now();
        //User user = userRepository.findUserByEmail(email);

        String transmissionDate = LocalDate.now().format(OpenApiUtil.DATE_FORMATTER);
        String transmissionTime = LocalDateTime.now().format(OpenApiUtil.TIME_FORMATTER);

        Map<String, String> header = OpenApiUtil.createHeaders("04e988f2-d086-495a-aa2f-67b0e911782f", OpenApiUrls.OPEN_ACCOUNT_AUTH);

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

        header = OpenApiUtil.createHeaders("04e988f2-d086-495a-aa2f-67b0e911782f", OpenApiUrls.INQUIRE_TRANSACTION_HISTORY);

        request = new HashMap<>();
        request.put("Header", header);
        request.put("accountNo", accountNo);
        request.put("transactionUniqueNo", transactionUniqueNo);

        response = OpenApiUtil.callApi(new URI(OpenApiUrls.DEMAND_DEPOSIT_URL + OpenApiUrls.INQUIRE_TRANSACTION_HISTORY), request);
        logger.error("response:{}", response);
        try {
            JsonNode rootNode = objectMapper.readTree(response.getBody());
            String summary = rootNode.path("REC").path("transactionSummary").asText();
            int code = Integer.parseInt(summary.substring(6));
            System.out.println("summary :"+code);
        } catch (Exception e) {
            throw new RuntimeException("err", e);
        }


        return response.getBody();
    }



}