package authutil

import (
	"encoding/base64"
	"net/http"
	"regexp"
	"strings"
)

var BasicRegex = regexp.MustCompile("Basic (.*)")
var BearerRegex = regexp.MustCompile("Bearer (.*)")

type BasicAuthorization struct {
	Username string
	Password string
}

type BearerAuthorizatoin string

func NewBasicAuthorization(h http.Header) *BasicAuthorization {
	authorization := h.Get("Authorization")
	if authorization == "" {
		return nil
	}

	parts := BasicRegex.FindStringSubmatch(authorization)
	if len(parts) != 2 {
		return nil
	}

	creds, err := base64.StdEncoding.DecodeString(parts[1])
	if err != nil {
		return nil
	}

	parts = strings.Split(string(creds), ":")

	if len(parts) != 2 {
		return nil
	}

	if parts[0] == "" || parts[1] == "" {
		return nil
	}

	return &BasicAuthorization{
		Username: parts[0],
		Password: parts[1],
	}
}
