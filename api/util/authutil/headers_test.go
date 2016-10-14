package authutil_test

import (
	"github.com/krjackso/treatmehealth/api/util/authutil"

	"encoding/base64"
	"net/http"
	"testing"
)

var basicCases = map[string]struct {
	headerValue string
	expected    *authutil.BasicAuthorization
}{
	"no header":   {"", nil},
	"not base64":  {"Basic username:password", nil},
	"no colon":    {"Basic " + base64.StdEncoding.EncodeToString([]byte("test")), nil},
	"no username": {"Basic " + base64.StdEncoding.EncodeToString([]byte(":password")), nil},
	"no password": {"Basic " + base64.StdEncoding.EncodeToString([]byte("username:")), nil},
	"not basic":   {"Bearer " + base64.StdEncoding.EncodeToString([]byte("username:password")), nil},
	"success": {
		"Basic " + base64.StdEncoding.EncodeToString([]byte("username:password")),
		&authutil.BasicAuthorization{Username: "username", Password: "password"},
	},
}

func TestNewBasicAuthorization(t *testing.T) {
	for name, tt := range basicCases {
		test := tt
		t.Run(name, func(t *testing.T) {
			header := http.Header{}
			header.Set("Authorization", test.headerValue)

			result := authutil.NewBasicAuthorization(header)

			if result != test.expected {
				if result != nil && test.expected != nil {
					if result.Username != test.expected.Username && result.Password != test.expected.Password {
						t.Errorf("Incorrect result")
					}
				} else {
					t.Errorf("Incorrect result")
				}
			}
		})
	}
}
