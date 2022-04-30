self.addEventListener('message', function(e) {
    let count = 0;

    var addMatrix = function(i, n, m, A, B, R) {
        for (var j = i * Math.round(n / 4); j < (j + 1) * Math.round(n / 4); j++) {
  
            for (var k = 0; k < m; k++) {
      
                R[j][k] = A[j][k] + B[j][k];
            }
      
        }
    };

    addMatrix(e.data[0], e.data[1], e.data[2], e.data[3], e.data[4], e.data[5]);

    self.postMessage(count);
}, false);