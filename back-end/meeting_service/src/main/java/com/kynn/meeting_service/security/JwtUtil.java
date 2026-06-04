package com.kynn.meeting_service.security;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtUtil {
  private final Key key;
  private final long expirationMillis;

  public JwtUtil(@Value("${app.jwt.secret}") String secret,
                 @Value("${app.jwt.expiration}") long expirationMillis) {
    this.key = Keys.hmacShaKeyFor(secret.getBytes());
    this.expirationMillis = expirationMillis;
  }

  public String generateToken(String subject, UUID uid) {
    Date now = new Date();
    Date exp = new Date(now.getTime() + expirationMillis);
    return Jwts.builder()
            .setSubject(subject)
            .setId(uid.toString())
            .setIssuedAt(now)
            .setExpiration(exp)
            .signWith(key)
            .compact();
  }

  public String extractSubject(String token) {
    return Jwts.parserBuilder().setSigningKey(key).build()
            .parseClaimsJws(token).getBody().getSubject();
  }

  public UUID extractId(String token) {
    return UUID.fromString(Jwts.parserBuilder().setSigningKey(key).build()
            .parseClaimsJws(token).getBody().getId());
  }

  public boolean validateToken(String token) {
    try {
      Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
      return true;
    } catch (JwtException ex) {
      return false;
    }
  }
}
