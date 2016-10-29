package models

import (
	"bytes"
	"crypto/rand"
	"crypto/sha512"
	"golang.org/x/crypto/pbkdf2"
	"time"
)

const (
	credSaltLen = 16
	credKeyLen  = 64
	credWork    = 100000
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
