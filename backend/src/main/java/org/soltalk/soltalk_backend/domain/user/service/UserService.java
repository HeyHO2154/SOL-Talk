package org.soltalk.soltalk_backend.domain.user.service;

import lombok.RequiredArgsConstructor;
import org.soltalk.soltalk_backend.domain.user.entity.User;
import org.soltalk.soltalk_backend.domain.user.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    /**
     * 회원가입
     * @param user
     * @return User
     */
    public User registerUser(User user) {
        // 비밀번호를 직접 저장 (실제 서비스에서는 보안 취약함)
        return userRepository.save(user);
    }

    /**
     * loginId로 User 찾아서 반환
     * @param loginId
     * @return Optional<User>
     */
    public Optional<User> findByLoginId(String loginId) {
        return userRepository.findByLoginId(loginId);
    }

    /**
     * userId로 User 찾아서 반환
     * @param userId
     * @return User
     */
    public User getUserById(Long userId) {
        return userRepository.findById(userId).orElse(null);
    }
}