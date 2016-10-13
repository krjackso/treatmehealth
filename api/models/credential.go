package models

import (
	"bytes"
	"crypto/rand"
	"crypto/sha512"
	"golang.org/x/crypto/pbkdf2"
)

const (
	saltLen       = 16
	keyLen        = 64
	newIterations = 10000
)

type Credential struct {
	Hash []byte `datastore:",noindex"`
	Salt []byte `datastore:",noindex"`
	Work int    `datastore:",noindex"`
}

func NewCredential(password string) Credential {
	salt := make([]byte, saltLen)
	_, err := rand.Read(salt)
	if err != nil {
		panic(err)
	}

	hash := pbkdf2.Key([]byte(password), salt, newIterations, keyLen, sha512.New)

	return Credential{
		Hash: hash,
		Salt: salt,
		Work: newIterations,
	}
}

func (self Credential) verify(password string) bool {
	hash := pbkdf2.Key([]byte(password), self.Salt, self.Work, keyLen, sha512.New)
	return bytes.Equal(hash, self.Hash)
}
