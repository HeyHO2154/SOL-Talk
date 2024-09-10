package org.soltalk.soltalk_backend.domain.account.service;

import java.util.List;

import org.soltalk.soltalk_backend.domain.account.projection.SummaryAccount;
import org.soltalk.soltalk_backend.domain.account.repository.AccountRepository;
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