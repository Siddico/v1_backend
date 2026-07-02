<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\DoctorProfile;
use App\Models\PatientProfile;
use App\Models\ResearcherProfile;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    private function getPhotoUrl(?string $image): ?string
    {
        if (! $image) {
            return null;
        }
        if (str_starts_with($image, 'http')) {
            return $image;
        }
        return asset('storage/' . $image);
    }

    private function formatUser(User $user): array
    {
        $roleName = optional($user->role)->name_of_role;

        $profile = match ($roleName) {
            'patient'    => $user->patientProfile,
            'doctor'     => $user->doctorProfile,
            'researcher' => $user->researcherProfile,
            default      => null,
        };

        $photoUrl = $this->getPhotoUrl($profile?->image ?? null);

        $phone  = $user->phone  ?? $profile?->phone  ?? null;
        $gender = $user->gender ?? $profile?->gender ?? null;

        return [
            'id'                 => $user->id,
            'full_name'          => $user->full_name,
            'email'              => $user->email,
            'phone'              => $phone,
            'gender'             => $gender,
            'photo_url'          => $photoUrl,
            'fcm_token'          => $user->fcm_token,
            'role'               => $roleName,
            'profile'            => $profile,
            'date_of_birth'      => $user->date_of_birth,
            'patient_profile'    => $roleName === 'patient' ? $profile : null,
            'doctor_profile'     => $roleName === 'doctor' ? $profile : null,
            'researcher_profile' => $roleName === 'researcher' ? $profile : null,
        ];
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $role = Role::where('name_of_role', $validated['role'])->firstOrFail();

        $user = User::create([
            'role_id'   => $role->id,
            'full_name' => $validated['full_name'],
            'email'     => $validated['email'],
            'password'  => Hash::make($validated['password']),
            'phone'     => $validated['phone'] ?? null,
            'gender'    => $validated['gender'] ?? null,
        ]);

        match ($validated['role']) {
            'patient' => PatientProfile::create([
                'user_id'   => $user->id,
                'full_name' => $validated['full_name'],
                'phone'     => $validated['phone'] ?? null,
                'gender'    => $validated['gender'] ?? null,
                'age'       => 0,
            ]),
            'doctor' => DoctorProfile::create([
                'user_id'        => $user->id,
                'full_name'      => $validated['full_name'],
                'phone'          => $validated['phone'] ?? null,
                'gender'         => $validated['gender'] ?? null,
                'license_number' => 'pending',
            ]),
            'researcher' => ResearcherProfile::create([
                'user_id'   => $user->id,
                'full_name' => $validated['full_name'],
                'phone'     => $validated['phone'] ?? null,
                'gender'    => $validated['gender'] ?? null,
            ]),
        };

        $user->load(['role', 'patientProfile', 'doctorProfile', 'researcherProfile']);
        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registration successful.',
            'data'    => [
                'token' => $token,
                'user'  => $this->formatUser($user),
            ],
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = $request->validated();

        /** @var User|null $user */
        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email or password.',
                'data'    => null,
            ], 401);
        }

        if (! empty($credentials['fcm_token'])) {
            $user->update(['fcm_token' => $credentials['fcm_token']]);
        }

        $user->load(['role', 'patientProfile', 'doctorProfile', 'researcherProfile']);
        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful.',
            'data'    => [
                'token' => $token,
                'user'  => $this->formatUser($user),
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully.',
            'data'    => null,
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load([
            'role',
            'patientProfile',
            'doctorProfile',
            'researcherProfile',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Authenticated user retrieved.',
            'data'    => [
                'user' => $this->formatUser($user),
            ],
        ]);
    }
}
