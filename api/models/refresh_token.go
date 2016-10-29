package models

import (
	"crypto/rand"
	"encoding/base64"
	"time"
)

const (
	refreshTokenLen    = 40
	refreshTokenExpire = 30 * time.Minute
)

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
