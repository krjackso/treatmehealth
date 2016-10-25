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

func NewBearerAuthorization(h http.Header) (bearer string, ok bool) {
	authorization := h.Get("Authorization")
	if authorization == "" {
		return "", false
	}

	parts := BearerRegex.FindStringSubmatch(authorization)
	if len(parts) != 2 {
		return "", false
	}

	return string(parts[1]), true
}
