package models

import (
	"cloud.google.com/go/datastore"
	"context"
	"time"

	"github.com/krjackso/treatmehealth/api/services"
)

type User struct {
	Id         int64 `datastore:"-"`
	Username   string
	Email      string
	Zip        string
	Dob        time.Time
	Credential Credential `json:"-" datastore:",noindex"`
	CreatedAt  time.Time  `json:"-"`
}

type UserModelImpl struct {
	Datastore *services.Datastore
}

type UserModel interface {
	GetById(context.Context, int64) (*User, error)
	GetByUsername(context.Context, string) (*User, error)
	GetByEmail(context.Context, string) (*User, error)
	Create(context.Context, string, string, Credential, string, time.Time) (*User, error)
	GetRefreshToken(context.Context, int64, string) (*RefreshToken, error)
	AddRefreshToken(context.Context, int64, *RefreshToken) error
}

func NewUserKey(ctx context.Context, id int64) *datastore.Key {
	return datastore.NewKey(ctx, "User", "", id, nil)
}

func NewRefreshTokenKey(ctx context.Context, userKey *datastore.Key, token string) *datastore.Key {
	return datastore.NewKey(ctx, "RefreshToken", token, 0, userKey)
}

func (self *UserModelImpl) GetById(ctx context.Context, id int64) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)
	key := NewUserKey(ctx, id)

	user := &User{Id: key.ID()}
	err := self.Datastore.Client.Get(ctx, key, user)

	if err == datastore.ErrNoSuchEntity {
		return nil, nil
	} else if err != nil {
		return nil, err
	}

	return user, nil
}

func (self *UserModelImpl) GetByUsername(ctx context.Context, username string) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)
	query := datastore.NewQuery("User").Filter("Username =", username).Limit(1)

	results := self.Datastore.Client.Run(ctx, query)

	var user User
	key, err := results.Next(&user)

	if err != nil {
		if err == datastore.Done {
			return nil, nil
		} else {
			return nil, err
		}
	}

	user.Id = key.ID()

	return &user, nil
}

func (self *UserModelImpl) GetByEmail(ctx context.Context, email string) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)
	query := datastore.NewQuery("User").Filter("Email =", email).Limit(1)

	results := self.Datastore.Client.Run(ctx, query)

	var user User
	key, err := results.Next(&user)

	if err != nil {
		if err == datastore.Done {
			return nil, nil
		} else {
			return nil, err
		}
	}

	user.Id = key.ID()

	return &user, nil
}

type CreateUserError string

func (e CreateUserError) Error() string {
	return string(e)
}

func (self *UserModelImpl) Create(ctx context.Context, username string, email string, credential Credential, zip string, dob time.Time) (*User, error) {
	ctx = self.Datastore.NewContext(ctx)

	// Create the user
	key := NewUserKey(ctx, 0)

	user := &User{
		Username:   username,
		Email:      email,
		Credential: credential,
		Zip:        zip,
		Dob:        dob.UTC(),
		CreatedAt:  time.Now().UTC(),
	}

	key, err := self.Datastore.Client.Put(ctx, key, user)
	if err != nil {
		return nil, err
	}

	user.Id = key.ID()

	return user, nil
}

func (self *UserModelImpl) GetRefreshToken(ctx context.Context, userId int64, token string) (*RefreshToken, error) {
	ctx = self.Datastore.NewContext(ctx)

	userKey := NewUserKey(ctx, userId)
	tokenKey := NewRefreshTokenKey(ctx, userKey, token)

	var refreshToken *RefreshToken
	err := self.Datastore.Client.Get(ctx, tokenKey, refreshToken)
	if err != nil {
		return nil, err
	}
	return refreshToken, nil
}

func (self *UserModelImpl) AddRefreshToken(ctx context.Context, userId int64, token *RefreshToken) error {
	ctx = self.Datastore.NewContext(ctx)

	userKey := NewUserKey(ctx, userId)
	tokenKey := NewRefreshTokenKey(ctx, userKey, token.Token)

	_, err := self.Datastore.Client.Put(ctx, tokenKey, token)
	if err != nil {
		println("Failed to put token")
		return err
	}

	query := datastore.NewQuery("RefreshToken").Ancestor(userKey).KeysOnly().Filter("ExpiresAt <=", time.Now().UTC())

	var n struct{}
	expiredTokens, err := self.Datastore.Client.GetAll(ctx, query, n)
	if err != nil {
		println("Failed to get old tokens")
		return err
	}

	err = self.Datastore.Client.DeleteMulti(ctx, expiredTokens)
	if err != nil {
		println("Failed to delete old tokens")
		return err
	}

	return nil
}
