package authutil

import (
	"fmt"
	"github.com/dgrijalva/jwt-go"
	"strconv"
	"time"
)

const (
	jwtIssuer       = "http://localhost"
	jwtSecret       = "supersecret"
	jwtAccessExpire = 30 * time.Minute
)

func NewAccessToken(userId int64) (token string, expiresAt int64) {
	expiresAt = time.Now().Add(jwtAccessExpire).Unix()

	claims := &jwt.StandardClaims{
		Issuer:    jwtIssuer,
		IssuedAt:  time.Now().Unix(),
		Audience:  "self",
		Subject:   strconv.FormatInt(userId, 10),
		ExpiresAt: expiresAt,
	}

	jwt := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	token, err := jwt.SignedString([]byte(jwtSecret))
	if err != nil {
		panic(err)
	}

	return token, expiresAt
}

func VerifyAccessToken(tokenString string) (userId int64, ok bool) {
	token, err := jwt.ParseWithClaims(tokenString, &jwt.StandardClaims{}, func(token *jwt.Token) (interface{}, error) {
		if token.Method.Alg() != jwt.SigningMethodHS256.Alg() {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}
		return []byte(jwtSecret), nil
	})

	if err != nil {
		return 0, false
	}

	claims, ok := token.Claims.(*jwt.StandardClaims)
	if !ok || !token.Valid {
		return 0, false
	}

	if !claims.VerifyIssuer(jwtIssuer, true) {
		return 0, false
	}

	if !claims.VerifyAudience("self", true) {
		return 0, false
	}

	userId, err = strconv.ParseInt(claims.Subject, 10, 64)
	if err != nil {
		return 0, false
	}

	return userId, true
}
