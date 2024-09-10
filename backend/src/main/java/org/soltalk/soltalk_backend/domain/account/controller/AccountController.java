package org.soltalk.soltalk_backend.domain.account.controller;

import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.soltalk.soltalk_backend.domain.account.service.AccountService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.net.URISyntaxException;

@AllArgsConstructor
@RequestMapping("/api/financial")
@RestController
public class AccountController {

    private final AccountService accountService;
    private static final Logger logger = LoggerFactory.getLogger(AccountController.class.getSimpleName());

    @PostMapping("/transfer/one_won")
    public ResponseEntity<String> transferOneWon(@RequestParam("accountNo") String accountNo,
                                                 @RequestParam("email") String email) throws URISyntaxException {
        logger.info("transferOneWon()...accountNo:{}, email:{}", accountNo, email);
        return ResponseEntity.ok(accountService.transferOneWon(accountNo, email));
    }
}
