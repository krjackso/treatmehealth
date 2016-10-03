package controllers_test

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestGet(t *testing.T) {
	req, _ := http.NewRequest("GET", "/api/users/1", nil)
	record := httptest.NewRecorder()
	router.ServeHTTP(record, req)
	if status := record.Code; status != http.StatusOK {
		t.Errorf("Incorrect status code. wanted %v but got %v", http.StatusOK, status)
	}

	req, _ = http.NewRequest("GET", "/api/users/2", nil)
	record = httptest.NewRecorder()
	router.ServeHTTP(record, req)
	if status := record.Code; status != http.StatusNotFound {
		t.Errorf("Incorrect status code. wanted %v but got %v", http.StatusNotFound, status)
	}

	req, _ = http.NewRequest("GET", "/api/users/asdf", nil)
	record = httptest.NewRecorder()
	router.ServeHTTP(record, req)
	if status := record.Code; status != http.StatusBadRequest {
		t.Errorf("Incorrect status code. wanted %v but got %v", http.StatusBadRequest, status)
	}

}
