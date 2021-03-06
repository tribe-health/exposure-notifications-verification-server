// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package otp

import (
	"context"
	"testing"
	"time"

	"github.com/google/exposure-notifications-verification-server/pkg/database"
)

func TestGenerateCode(t *testing.T) {
	// Run through a whole bunch of iterations.
	for j := 0; j < 1000; j++ {
		code, err := GenerateCode(8)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}

		if got := len(code); got != 8 {
			t.Fatalf("code is wrong length want 8, got %v", got)
		}

		for i, c := range code {
			if c < '0' || c > '9' {
				t.Errorf("code[%v]: %v outside expected range 0-9", i, c)
			}
		}
	}
}

func TestIssue(t *testing.T) {
	t.Parallel()
	db := database.NewTestDatabase(t)
	ctx := context.Background()

	numCodes := 100
	codes := make([]string, 0, numCodes)
	for i := 0; i < numCodes; i++ {
		otp := Request{
			DB:        db,
			Length:    8,
			ExpiresAt: time.Now().Add(time.Hour),
			TestType:  "confirmed",
		}
		code, err := otp.Issue(ctx, 10)
		if err != nil {
			t.Errorf("error generating code: %v", err)
		}
		codes = append(codes, code)
	}

	if got := len(codes); got != numCodes {
		t.Errorf("wrong number of codes, want: %v got %v", numCodes, got)
	}

	for _, code := range codes {
		verCode, err := db.FindVerificationCode(code)
		if err != nil {
			t.Errorf("didn't find previously saved code")
		}
		if verCode.Code != code {
			t.Fatalf("loaded code doesn't match requested code")
		}
	}
}
