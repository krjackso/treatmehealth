package models

import (
	"bytes"
	"crypto/rand"
	"crypto/sha512"
	"encoding/base64"
	"github.com/dgrijalva/jwt-go"
	"golang.org/x/crypto/pbkdf2"
	"time"
)

const (
	credSaltLen = 16
	credKeyLen  = 64
	credWork    = 100000

	jwtIssuer          = "http://localhost"
	jwtSecret          = "supersecret"
	jwtAccessExpire    = 5 * time.Minute
	refreshTokenLen    = 40
	refreshTokenExpire = 5 * time.Minute
)

type Credential struct {
	Hash      []byte    `datastore:",noindex"`
	Salt      []byte    `datastore:",noindex"`
	Work      int       `datastore:",noindex"`
	CreatedAt time.Time `datastore:",noindex"`
}

func NewCredential(password string) Credential {
	salt := make([]byte, credSaltLen)
	_, err := rand.Read(salt)
	if err != nil {
		panic(err)
	}

	hash := pbkdf2.Key([]byte(password), salt, credWork, credKeyLen, sha512.New)

	return Credential{
		Hash:      hash,
		Salt:      salt,
		Work:      credWork,
		CreatedAt: time.Now().UTC(),
	}
}

func (self Credential) Verify(password string) bool {
	hash := pbkdf2.Key([]byte(password), self.Salt, self.Work, credKeyLen, sha512.New)
	return bytes.Equal(hash, self.Hash)
}

func NewAccessToken(userId int64) (token string, expiresAt int64) {
	expiresAt = time.Now().Add(jwtAccessExpire).Unix()

	claims := &jwt.StandardClaims{
		Issuer:    jwtIssuer,
		IssuedAt:  time.Now().Unix(),
		Audience:  "self",
		Subject:   string(userId),
		ExpiresAt: expiresAt,
	}

	jwt := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	token, err := jwt.SignedString([]byte(jwtSecret))
	if err != nil {
		panic(err)
	}

	return token, expiresAt
}

type RefreshToken struct {
	ExpiresAt time.Time
	Token     string `datastore:"-"`
}

func NewRefreshToken() *RefreshToken {
	bytes := make([]byte, refreshTokenLen)
	_, err := rand.Read(bytes)
	if err != nil {
		panic(err)
	}

	return &RefreshToken{
		ExpiresAt: time.Now().UTC().Add(refreshTokenExpire),
		Token:     base64.StdEncoding.EncodeToString(bytes),
	}
}
