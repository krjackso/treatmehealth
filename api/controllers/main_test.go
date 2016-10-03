package controllers_test

import (
	"context"
	"github.com/krjackso/treatmehealth/api/controllers"
	"github.com/krjackso/treatmehealth/api/models"
	"github.com/pressly/chi"
	"os"
	"testing"
)

type UserModelMock struct{}

func (self *UserModelMock) GetById(ctx context.Context, id int64) (*models.User, error) {
	if id == 1 {
		user := &models.User{
			Id:        1,
			FirstName: "Test",
			LastName:  "User",
			Email:     "testuser@example.com",
			Username:  "testuser",
		}
		return user, nil
	} else {
		return nil, nil
	}
}

func (self *UserModelMock) GetByUsername(ctx context.Context, username string) (*models.User, error) {
	if username == "testuser" {
		user := &models.User{
			Id:        1,
			FirstName: "Test",
			LastName:  "User",
			Email:     "testuser@example.com",
			Username:  "testuser",
		}
		return user, nil
	} else {
		return nil, nil
	}
}

var (
	router *chi.Mux
)

func TestMain(m *testing.M) {
	userModel := &UserModelMock{}
	router = controllers.Bootstrap(userModel)
	ret := m.Run()
	os.Exit(ret)
}
