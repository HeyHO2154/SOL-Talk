package org.soltalk.soltalk_backend.account.service;

import java.util.List;

import org.soltalk.soltalk_backend.account.dto.SummaryAccountData;
import org.soltalk.soltalk_backend.account.projection.SummaryAccount;
import org.soltalk.soltalk_backend.account.repository.AccountRepository;
import org.springframework.stereotype.Service;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AccountService {

    private final AccountRepository accountRepository;

    public List<SummaryAccount> findActiveAccounts() {
        return accountRepository.findSummaryAccounts();
    }
}