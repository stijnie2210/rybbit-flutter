import 'package:flutter_test/flutter_test.dart';
import 'package:rybbit_flutter/src/pattern_matcher.dart';

void main() {
  group('PatternMatcher', () {
    group('exact matching', () {
      test('matches exact paths', () {
        expect(
          PatternMatcher.shouldSkipPath('/admin/users', ['/admin/users']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/admin/users', ['/admin/settings']),
          false,
        );
      });

      test('handles empty patterns', () {
        expect(
          PatternMatcher.shouldSkipPath('/any/path', []),
          false,
        );
      });
    });

    group('wildcard matching', () {
      test('matches paths with trailing wildcards', () {
        expect(
          PatternMatcher.shouldSkipPath('/admin/users', ['/admin/*']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/admin/settings/advanced', ['/admin/*']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/public/users', ['/admin/*']),
          false,
        );
      });

      test('matches paths with leading wildcards', () {
        expect(
          PatternMatcher.shouldSkipPath('/user/dashboard', ['*/dashboard']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/admin/dashboard', ['*/dashboard']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/user/settings', ['*/dashboard']),
          false,
        );
      });

      test('matches paths with middle wildcards', () {
        expect(
          PatternMatcher.shouldSkipPath('/api/debug/info', ['*/debug/*']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/v1/debug/logs', ['*/debug/*']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/api/users/info', ['*/debug/*']),
          false,
        );
      });

      test('matches paths with full wildcards', () {
        expect(
          PatternMatcher.shouldSkipPath('/anything/goes/here', ['*']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/debug', ['*debug*']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/api/debug/info', ['*debug*']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/user/settings', ['*debug*']),
          false,
        );
      });
    });

    group('multiple patterns', () {
      test('matches any pattern in the list', () {
        final patterns = ['/admin/*', '*/debug/*', '/temp'];
        
        expect(
          PatternMatcher.shouldSkipPath('/admin/users', patterns),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/api/debug/info', patterns),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/temp', patterns),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/public/users', patterns),
          false,
        );
      });
    });

    group('edge cases', () {
      test('handles root path', () {
        expect(
          PatternMatcher.shouldSkipPath('/', ['/']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/', ['/*']),
          true,
        );
      });

      test('handles paths without leading slash', () {
        expect(
          PatternMatcher.shouldSkipPath('admin/users', ['admin/*']),
          true,
        );
      });

      test('handles empty path', () {
        expect(
          PatternMatcher.shouldSkipPath('', ['']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('', ['*']),
          true,
        );
      });

      test('handles invalid regex patterns gracefully', () {
        // These patterns have regex special characters that should be escaped
        expect(
          PatternMatcher.shouldSkipPath('/test.html', ['/test.html']),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath('/api/v1', ['/api/v+']),
          false, // + is treated as literal character, not regex
        );
      });

      test('handles complex paths', () {
        expect(
          PatternMatcher.shouldSkipPath(
            '/api/v1/users/123/settings', 
            ['/api/*/users/*/settings']
          ),
          true,
        );
        
        expect(
          PatternMatcher.shouldSkipPath(
            '/deeply/nested/path/structure/here', 
            ['/deeply/nested/*']
          ),
          true,
        );
      });
    });

    group('real-world patterns', () {
      test('common skip patterns', () {
        final commonPatterns = [
          '/debug/*',
          '/admin/internal/*',
          '*/health-check',
          '/api/docs/*',
          '*/_dev/*',
          '/temp',
        ];

        // Should skip
        expect(PatternMatcher.shouldSkipPath('/debug/logs', commonPatterns), true);
        expect(PatternMatcher.shouldSkipPath('/admin/internal/stats', commonPatterns), true);
        expect(PatternMatcher.shouldSkipPath('/app/health-check', commonPatterns), true);
        expect(PatternMatcher.shouldSkipPath('/api/docs/swagger', commonPatterns), true);
        expect(PatternMatcher.shouldSkipPath('/project/_dev/test', commonPatterns), true);
        expect(PatternMatcher.shouldSkipPath('/temp', commonPatterns), true);

        // Should not skip
        expect(PatternMatcher.shouldSkipPath('/home', commonPatterns), false);
        expect(PatternMatcher.shouldSkipPath('/admin/users', commonPatterns), false);
        expect(PatternMatcher.shouldSkipPath('/api/users', commonPatterns), false);
        expect(PatternMatcher.shouldSkipPath('/dashboard', commonPatterns), false);
      });
    });
  });
}