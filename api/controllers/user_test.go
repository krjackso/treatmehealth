package controllers_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"
)

var getCases = map[string]struct {
	userId     string
	statusCode int
}{
	"user exists":         {"1", http.StatusOK},
	"user does not exist": {"2", http.StatusNotFound},
	"invalid user id":     {"asdf", http.StatusBadRequest},
}

func TestGet(t *testing.T) {
	for name, tt := range getCases {
		test := tt
		t.Run(name, func(t *testing.T) {
			req, _ := http.NewRequest("GET", "/api/users/"+test.userId, nil)
			record := httptest.NewRecorder()
			router.ServeHTTP(record, req)
			if status := record.Code; status != test.statusCode {
				t.Errorf("Wanted status code %v but got %v", test.statusCode, status)
			}
		})
	}
}

type PutUserData struct {
	Username string
	Email    string
	Password string
	Zip      string
	Dob      string
}

var putCases = map[string]struct {
	data       PutUserData
	statusCode int
}{
	"short username": {PutUserData{"u", "email@example.com", "password", "90210", "07/02/1992"}, http.StatusBadRequest},
	"short password": {PutUserData{"exampleuser", "email@example.com", "p", "90210", "07/02/1992"}, http.StatusBadRequest},
	"bad email":      {PutUserData{"exampleuser", "email", "password", "90210", "07/02/1992"}, http.StatusBadRequest},
	"missing zip":    {PutUserData{"exampleuser", "email@example.com", "password", "", "07/02/1992"}, http.StatusBadRequest},
	"bad birthday":   {PutUserData{"exampleuser", "email@example.com", "password", "90210", "birthday"}, http.StatusBadRequest},
	"username taken": {PutUserData{"testuser", "email@example.com", "password", "90210", "07/02/1992"}, http.StatusConflict},
	"email taken":    {PutUserData{"exampleuser", "testuser@example.com", "password", "90210", "07/02/1992"}, http.StatusConflict},
	"under 18":       {PutUserData{"exampleuser", "email@example.com", "password", "90210", "07/02/2016"}, http.StatusBadRequest},
	"successful":     {PutUserData{"exampleuser", "email@example.com", "password", "90210", "07/02/1992"}, http.StatusCreated},
}

func TestPut(t *testing.T) {
	for name, tt := range putCases {
		test := tt
		t.Run(name, func(t *testing.T) {
			body, _ := json.Marshal(test.data)
			req, _ := http.NewRequest("PUT", "/api/users", bytes.NewReader(body))

			record := httptest.NewRecorder()
			router.ServeHTTP(record, req)
			if status := record.Code; status != test.statusCode {
				t.Errorf("Wanted status code %v but got %v", test.statusCode, status)
			}
		})
	}
}
