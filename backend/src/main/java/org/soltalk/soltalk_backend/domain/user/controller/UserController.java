package org.soltalk.soltalk_backend.domain.user.controller;

import org.soltalk.soltalk_backend.domain.user.entity.User;
import org.soltalk.soltalk_backend.domain.user.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * 회원가입
     * @param user
     * @return
     */
    @PostMapping("/register")
    public ResponseEntity<String> registerUser(@RequestBody User user) {
        // 로그인 아이디 중복 확인
        Optional<User> existingUser = userService.findByLoginId(user.getLoginId());
        if (existingUser.isPresent()) {
            return ResponseEntity.badRequest().body("Login ID already exists");
        }
        // 비밀번호가 비어있는 경우 예외 처리
        if (user.getPassword() == null || user.getPassword().isEmpty()) {
            return ResponseEntity.badRequest().body("Password cannot be empty");
        }
        User newUser = userService.registerUser(user);
        return ResponseEntity.ok("User registered successfully");
    }

    /**
     * 로그인
     * @param user
     * @return
     */
    @PostMapping("/login")
    public ResponseEntity<String> loginUser(@RequestBody User user) {
        Optional<User> existingUser = userService.findByLoginId(user.getLoginId());
        if (existingUser.isPresent() && user.getPassword().equals(existingUser.get().getPassword())) {
            return ResponseEntity.ok("Login successful");
        }
        return ResponseEntity.status(401).body("Invalid login credentials");
    }

    /**
     * 사용자 정보 조회
     * @param userId
     * @return
     */
    @GetMapping("/{userId}")
    public ResponseEntity<User> getUserById(@PathVariable Long userId) {
        User user = userService.getUserById(userId);
        if (user != null) {
            return ResponseEntity.ok(user);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}